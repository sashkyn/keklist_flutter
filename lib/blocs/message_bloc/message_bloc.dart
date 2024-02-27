import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/services/entities/message.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/services/hive/constants.dart';
import 'package:keklist/services/hive/entities/message/message_object.dart';
import 'package:keklist/services/message_service/message_service.dart';
import 'package:uuid/uuid.dart';

part 'message_event.dart';
part 'message_state.dart';

// TODO: написать сервис который будет удобен в интерфейсе для взаимодействия с чатом и сообщениями.

class MessageBloc extends Bloc<MessageEvent, MessageState> with DisposeBag {
  // TODO: extract to DI
  final MessageService _messageService = MessageOpenAIService();
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
      final List<Message> messages = _hiveObjects
          .map((messageObject) => messageObject.toMessage())
          .where((message) => message.sender != MessageSender.system)
          .mySortedBy((message) => message.timestamp)
          .toList();
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
    final MessageHistory messageHistory = await _messageService.initializeDiscussion(
      rootMind: event.mind,
      rootMindChildren: event.mindChildren,
      initMessageText: _makeInitialSystemPromt(
        mind: event.mind,
        mindChildren: event.mindChildren,
      ),
    );
    try {
      final Map<String, MessageObject> messageObjects = {};
      for (final Message message in messageHistory.messages) {
        final MessageObject messageObject = message.toObject();
        messageObjects[messageObject.id] = messageObject;
      }
      await _hiveBox.putAll(messageObjects);
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
    emit(MessageLoadingStatus(isLoading: false));
  }

  FutureOr<void> _sendMessage(MessageSend event, Emitter emit) async {
    emit(MessageLoadingStatus(isLoading: true));
    final Message userMessage = Message(
      id: const Uuid().v4(),
      text: event.message,
      rootMindId: event.rootMindId,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
    );
    final MessageObject userMessageObject = userMessage.toObject();
    try {
      await _hiveBox.put(userMessageObject.id, userMessageObject);
    } catch (error) {
      emit(MessageError(message: '$error'));
    }

    final Message openAIAnswerMessage = await _messageService.requestAnswer(
      history: MessageHistory(
        messages: _hiveObjects.map((object) => object.toMessage()).mySortedBy((object) => object.timestamp).toList(),
        rootMindId: event.rootMindId,
      ),
    );

    try {
      await _hiveBox.put(openAIAnswerMessage.id, openAIAnswerMessage.toObject());
    } catch (error) {
      emit(MessageError(message: '$error'));
    }
    emit(MessageLoadingStatus(isLoading: false));
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
    ACT YOUR SELF LIKE PRO SPECIALIST.
    It's my mind with the note - ${mind.note}. 
    I've set this emoji for the note - ${mind.emoji}.
    $mindChildrenPromt
    It's important to use language of message content for feedback otherwise I dont know english.
    You have only 220 tokens to each answer. PLEASE Give your further answers as short as possible.
    ALWAYS ASK something in the end of your message.
    DO NOT USE MARKDOWNS.
    ''';
    return prompt;
  }
}
