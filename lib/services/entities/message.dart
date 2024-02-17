import 'package:equatable/equatable.dart';
import 'package:keklist/services/hive/entities/message/message_object.dart';

class Message with EquatableMixin {
  final String id;
  final String text;
  final String rootMindId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.rootMindId,
    required this.timestamp,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        text,
        rootMindId,
        timestamp.millisecondsSinceEpoch,
      ];

  MessageObject toObject() => MessageObject()
    ..id = id
    ..text = text
    ..rootMindId = rootMindId
    ..timestamp = timestamp;
}
