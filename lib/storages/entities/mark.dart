import 'package:equatable/equatable.dart';

class Mark extends Equatable {
  final String id;
  final String emoji;
  final String note;
  final int dayIndex;
  final int creationDate;
  final int sortIndex;

  const Mark({
    required this.id,
    required this.note,
    required this.emoji,
    required this.dayIndex,
    required this.creationDate,
    required this.sortIndex,
  });

  @override
  List<Object?> get props => [id];

  Mark.fromSupabaseJson(Map<String, dynamic> json)
      : id = json['uuid'] ?? 0,
        emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'],
        // creationDate = json['created_at'] ?? 0, // TODO: сделать нормальный парсинг TimeStamp
        creationDate = 0,
        sortIndex = json["sort_index"] ?? 0;

  Map<String, dynamic> toSupabaseJson({required String userId}) => {
        'user_id': userId,
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
}
