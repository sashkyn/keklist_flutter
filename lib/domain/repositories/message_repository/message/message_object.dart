import 'package:hive/hive.dart';
import 'package:keklist/core/enum_from_string.dart';
import 'package:keklist/domain/services/entities/message.dart';

part 'message_object.g.dart';

@HiveType(typeId: 3)
final class MessageObject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String text;

  @HiveField(2)
  late String rootMindId;

  @HiveField(3)
  late DateTime timestamp;

  @HiveField(4)
  late String? sender;

  MessageObject();

  Message toMessage() => Message(
        id: id,
        text: text,
        rootMindId: rootMindId,
        timestamp: timestamp,
        sender: enumFromString(value: sender, fromValues: MessageSender.values) ?? MessageSender.assistant,
      );
}
