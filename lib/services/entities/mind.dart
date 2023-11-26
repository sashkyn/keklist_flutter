import 'package:equatable/equatable.dart';
import 'package:keklist/services/hive/entities/mind/mind_object.dart';

class Mind with EquatableMixin {
  final String id;
  final String emoji;
  final String note;
  final int dayIndex;
  final DateTime creationDate;
  final int sortIndex;
  final String? rootId;

  Mind({
    required this.id,
    required this.note,
    required this.emoji,
    required this.dayIndex,
    required this.creationDate,
    required this.sortIndex,
    required this.rootId,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        emoji,
        note,
        sortIndex,
        dayIndex,
        creationDate.millisecondsSinceEpoch,
      ];

  Mind.fromSupabaseJson(Map<String, dynamic> json)
      : id = json['uuid'] ?? 'heheh',
        emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'],
        creationDate = DateTime.parse(json['created_at']).toUtc(),
        sortIndex = json["sort_index"] ?? 0,
        rootId = json["root_id"];

  Map<String, dynamic> toSupabaseJson({required String userId}) {
    return {
      'user_id': userId,
      'uuid': id,
      'emoji': emoji,
      'note': note,
      'day_index': dayIndex,
      'sort_index': sortIndex,
      'created_at': creationDate.toUtc().toIso8601String(),
      'root_id': rootId,
    };
  }

  Map<String, dynamic> toShortJson() => {
        'uuid': id,
        'emoji': emoji,
        'note': note,
        'day_index': dayIndex,
        'sort_index': sortIndex,
      };

  List<String> toCSVEntry() => [
        id,
        emoji,
        note,
        dayIndex.toString(),
        sortIndex.toString(),
        creationDate.toString(),
      ];

  Mind copyWith({
    String? id,
    String? emoji,
    String? note,
    int? dayIndex,
    DateTime? creationDate,
    int? sortIndex,
    String? rootId,
  }) {
    return Mind(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      dayIndex: dayIndex ?? this.dayIndex,
      creationDate: creationDate ?? this.creationDate,
      sortIndex: sortIndex ?? this.sortIndex,
      rootId: rootId ?? this.rootId,
    );
  }

  MindObject toObject({required bool isUploadedToServer}) => MindObject()
    ..id = id
    ..emoji = emoji
    ..note = note
    ..dayIndex = dayIndex
    ..creationDate = creationDate
    ..isUploadedToServer = isUploadedToServer
    ..sortIndex = sortIndex
    ..rootId = rootId;
}
