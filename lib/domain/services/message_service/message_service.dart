import 'package:keklist/domain/services/entities/message.dart';
import 'package:keklist/domain/services/entities/message_history.dart';
import 'package:keklist/domain/services/entities/mind.dart';

abstract class MessageService {
  Future<MessageHistory> initializeDiscussion({
    required Mind rootMind,
    required List<Mind> rootMindChildren,
    required String initMessageText,
  });
  Future<Message> requestAnswer({required MessageHistory history});
}
