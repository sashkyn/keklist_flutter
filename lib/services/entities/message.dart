import 'package:equatable/equatable.dart';
import 'package:keklist/core/enum_from_string.dart';
import 'package:keklist/services/hive/entities/message/message_object.dart';

class Message with EquatableMixin {
  final String id;
  final String text;
  final String rootMindId;
  final DateTime timestamp;
  final MessageSender sender;

  Message({
    required this.id,
    required this.text,
    required this.rootMindId,
    required this.timestamp,
    required this.sender,
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
    ..timestamp = timestamp
    ..sender = stringFromEnum(sender);
}

enum MessageSender { user, system, assistant }
