import 'dart:async';

import 'package:chat_gpt_api/app/chat_gpt.dart';
import 'package:chat_gpt_api/app/model/data_model/chat/chat_completion.dart';
import 'package:chat_gpt_api/app/model/data_model/chat/chat_request.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/services/entities/message.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/services/hive/constants.dart';
import 'package:keklist/services/hive/entities/message/message_object.dart';
import 'package:uuid/uuid.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> with DisposeBag {
  final ChatGPT _chatGpt = ChatGPT.builder(token: dotenv.get('OPEN_AI_TOKEN'));
  final Box<MessageObject> _hiveBox = Hive.box<MessageObject>(HiveConstants.messageChatBoxName);
  Iterable<MessageObject> get _hiveObjects => _hiveBox.values;
  Stream<MessageObject?> get _hiveObjectsStream =>
      _hiveBox.watch().map((BoxEvent event) => event.value as MessageObject?);

  MessageBloc() : super(MessageChat(messages: [])) {
    on<MessageGetAll>(_getMessages);
    on<MessageClearChatWithMind>(_clearMessages);
    on<MessageStartDiscussion>(_startNewDiscussion);
    on<MessageSend>(_sendMessage);

    _hiveObjectsStream.listen((MessageObject? messageObject) => add(MessageGetAll())).disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }

  FutureOr<void> _getMessages(MessageGetAll event, Emitter emit) {
    try {
      final List<Message> messages =
          _hiveObjects.map((object) => object.toMessage()).mySortedBy((e) => e.timestamp).toList();
      emit(MessageChat(messages: messages));
    } catch (e) {
      emit(MessageError(message: '$e'));
    }
  }

  FutureOr<void> _clearMessages(MessageClearChatWithMind event, Emitter emit) async {
    try {
      final Iterable<String> messageObjectIdsToDelete =
          _hiveObjects.where((element) => element.rootMindId == event.rootMindId).map((object) => object.id).toList();
      await _hiveBox.deleteAll(messageObjectIdsToDelete);
      add(MessageGetAll());
    } catch (e) {
      emit(MessageError(message: '$e'));
    }
  }

  FutureOr<void> _startNewDiscussion(MessageStartDiscussion event, Emitter emit) async {
    // await _hiveBox.clear();
    emit(MessageLoadingStatus(isLoading: true));
    try {
      await _hiveBox.deleteAll(
        _hiveObjects.where((element) => element.rootMindId == event.mind.id).map((object) => object.id).toList(),
      );
    } catch (e) {
      emit(MessageError(message: '$e'));
      return;
    }
    final String prompt = _makeStartingPromt(event.mind);
    final ChatCompletion? chatCompletion = await _chatGpt.chatCompletion(
      request: ChatRequest(
        model: 'gpt-3.5-turbo-0125',
        maxTokens: 256,
        messages: [
          ChatMessage(
            role: 'system',
            content: prompt,
          ),
        ],
      ),
    );
    emit(MessageLoadingStatus(isLoading: false));
    try {
      if (chatCompletion == null) {
        throw Exception('There is no chat completion!');
      }

      if (chatCompletion.choices == null) {
        throw Exception('There are no chat completion choices!');
      }
      final String messageText = chatCompletion.choices!.map((choice) => choice.message?.content).join('\n');
      final Message message = Message(
        id: const Uuid().v4(),
        text: messageText,
        rootMindId: event.mind.id,
        timestamp: DateTime.now(),
      );
      final MessageObject messageObject = message.toObject();
      _hiveBox.put(messageObject.id, messageObject);
    } catch (e) {
      emit(MessageError(message: '$e'));
    }
  }

  FutureOr<void> _sendMessage(MessageSend event, Emitter emit) async {
    final Message message = Message(
      id: const Uuid().v4(),
      text: event.message,
      rootMindId: event.rootMindId,
      timestamp: DateTime.now(),
    );
    final MessageObject messageObject = message.toObject();
    try {
      await _hiveBox.put(messageObject.id, messageObject);
    } on Exception catch (e) {
      emit(MessageError(message: '$e'));
    }
  }

  // TODO: add additional chlidren minds if any.

  String _makeStartingPromt(Mind mind) {
    final String prompt = '''
        It's my mind with the note - ${mind.note}. 
        I've set this emoji for the note - ${mind.emoji}.
        Could you give short comment like a pro psycologist?
        It's important to use language of message content for feedback otherwise I dont know english.
    ''';
    return prompt;
  }
}
