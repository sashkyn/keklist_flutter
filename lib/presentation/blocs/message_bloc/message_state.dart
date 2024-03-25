part of 'message_bloc.dart';

sealed class MessageState with EquatableMixin {
  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [];
}

class MessageChat extends MessageState {
  final List<Message> messages;

  MessageChat({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class MessageLoadingStatus extends MessageState {
  final bool isLoading;

  MessageLoadingStatus({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}

class MessageError extends MessageState {
  final String message;

  MessageError({required this.message});

  @override
  List<Object?> get props => [message];
}
