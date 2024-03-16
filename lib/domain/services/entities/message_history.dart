import 'package:keklist/domain/services/entities/message.dart';

final class MessageHistory {
  final String rootMindId;
  final List<Message> messages;

  MessageHistory({
    required this.messages,
    required this.rootMindId,
  });
}