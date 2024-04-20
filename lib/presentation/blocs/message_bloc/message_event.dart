part of 'message_bloc.dart';

sealed class MessageEvent with EquatableMixin {
  @override
  bool? get stringify => true;
  @override
  List<Object?> get props => [];
}

class MessageGetAll extends MessageEvent {
  MessageGetAll();
}

class MessageClearChatWithMind extends MessageEvent {
  final String rootMindId;

  MessageClearChatWithMind({required this.rootMindId});

  @override
  List<Object?> get props => [rootMindId];
}

class MessageStartDiscussion extends MessageEvent {
  final Mind mind;
  final List<Mind> mindChildren;

  MessageStartDiscussion({
    required this.mind,
    required this.mindChildren,
  });

  @override
  List<Object?> get props => [mind, mindChildren];
}

class MessageSend extends MessageEvent {
  final String message;
  final String rootMindId;

  MessageSend({
    required this.message,
    required this.rootMindId,
  });

  @override
  List<Object?> get props => [message, rootMindId];
}
