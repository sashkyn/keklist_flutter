import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// TODO: написать сервис который будет удобен в интерфейсе для взаимодействия с чатом и сообщениями.

class MessageBloc extends Bloc<MessageEvent, MessageState> with DisposeBag {
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
          _hiveObjects.map((object) => object.toMessage()).mySortedBy((object) => object.timestamp).toList();
      emit(MessageChat(messages: messages));
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
  }

  FutureOr<void> _clearMessages(MessageClearChatWithMind event, Emitter emit) async {
    try {
      final Iterable<String> messageObjectIdsToDelete =
          _hiveObjects.where((element) => element.rootMindId == event.rootMindId).map((object) => object.id).toList();
      await _hiveBox.deleteAll(messageObjectIdsToDelete);
      add(MessageGetAll());
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
  }

  FutureOr<void> _startNewDiscussion(MessageStartDiscussion event, Emitter emit) async {
    emit(MessageLoadingStatus(isLoading: true));
    try {
      await _hiveBox.deleteAll(
        _hiveObjects.where((element) => element.rootMindId == event.mind.id).map((object) => object.id).toList(),
      );
    } catch (error) {
      emit(MessageError(message: '$error'));
      return;
    }

    final OpenAIChatCompletionModel chatCompletion = await _requestChatCompletionFromAI(
      mind: event.mind,
      mindChildren: event.mindChildren,
    );
    emit(MessageLoadingStatus(isLoading: false));
    try {
      final Message message = _getLastMessage(chatCompletion, event);
      final MessageObject messageObject = message.toObject();
      _hiveBox.put(messageObject.id, messageObject);
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
  }

  Future<OpenAIChatCompletionModel> _requestChatCompletionFromAI({
    required Mind mind,
    required List<Mind> mindChildren,
  }) async {
    final String prompt = _makeInitialSystemPromt(
      mind: mind,
      mindChildren: mindChildren,
    );
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
      ],
      role: OpenAIChatMessageRole.system,
    );

    // all messages to be sent.
    final requestMessages = [systemMessage];

    final OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      // model: "gpt-3.5-turbo-1106",
      model: 'gpt-4-0125-preview',
      n: 1,
      seed: 6,
      messages: requestMessages,
      temperature: 0.2, // 0.2 determined, 0.8 more random, 2.0 very random
      maxTokens: 256,
    );
    return chatCompletion;
  }

  Message _getLastMessage(OpenAIChatCompletionModel chatCompletion, MessageStartDiscussion event) {
    if (chatCompletion.choices.isEmpty) {
      throw Exception('There are no chat completion choices!');
    }
    final OpenAIChatCompletionChoiceModel firstChoice = chatCompletion.choices.first;
    if (firstChoice.message.content == null) {
      throw Exception('There are no chat completion choices!');
    }
    final OpenAIChatCompletionChoiceMessageContentItemModel? firstChoiceContent = firstChoice.message.content?.first;
    if (firstChoiceContent == null) {
      throw Exception('There are no chat completion choices!');
    }
    final String? messageText = firstChoiceContent.text;
    if (messageText == null || messageText.isEmpty) {
      throw Exception('There is no message!');
    }
    final Message message = Message(
      id: const Uuid().v4(),
      text: messageText,
      rootMindId: event.mind.id,
      timestamp: DateTime.now(),
    );
    return message;
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
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
  }

  String _makeInitialSystemPromt({
    required Mind mind,
    required List<Mind> mindChildren,
  }) {
    final String mindChildrenPromt = () {
      if (mindChildren.isEmpty) {
        return '';
      }
      final String mindChildrenPromt = mindChildren.map((mind) => '${mind.emoji} - ${mind.note}').join(';\n');
      return 'Here is my list of comments for this mind:\n$mindChildrenPromt';
    }();

    final String prompt = '''
        It's my mind with the note - ${mind.note}. 
        I've set this emoji for the note - ${mind.emoji}.
        $mindChildrenPromt
        Could you give short comment like a pro psycologist?
        It's important to use language of message content for feedback otherwise I dont know english.
    ''';
    return prompt;
  }
}
