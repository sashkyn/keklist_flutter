import 'package:hive/hive.dart';
import 'package:rememoji/services/entities/mind.dart';

part 'mind_object.g.dart';

@HiveType(typeId: 1)
class MindObject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String emoji;

  @HiveField(2)
  late String note;

  @HiveField(3)
  late int dayIndex;

  @HiveField(4)
  late DateTime creationDate;

  @HiveField(5)
  late int sortIndex;

  @HiveField(6, defaultValue: false)
  late bool isUploadedToServer;

  @HiveField(7, defaultValue: null)
  late String? rootId;

  MindObject();

  Mind toMind() => Mind(
        id: id,
        emoji: emoji,
        note: note,
        dayIndex: dayIndex,
        creationDate: creationDate,
        sortIndex: sortIndex,
        rootId: rootId,
      );
}
