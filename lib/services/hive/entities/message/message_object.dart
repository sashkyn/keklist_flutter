import 'package:hive/hive.dart';
import 'package:keklist/services/entities/message.dart';

part 'message_object.g.dart';

@HiveType(typeId: 3)
class MessageObject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String text;

  @HiveField(2)
  late String rootMindId;

  @HiveField(3)
  late DateTime timestamp;

  MessageObject();

  Message toMessage() => Message(
        id: id,
        text: text,
        rootMindId: rootMindId,
        timestamp: timestamp,
      );
}
