import 'package:equatable/equatable.dart';

class Mark extends Equatable {
  final String uuid;
  final String emoji;
  final String note;
  final int dayIndex;
  final int creationDate;
  final int sortIndex;

  Mark({
    required this.uuid,
    required this.note,
    required this.emoji,
    required this.dayIndex,
    required this.creationDate,
    required this.sortIndex,
  });

  @override
  List<Object?> get props => [uuid];

  Mark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'] ?? 0,
        emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'],
        creationDate = json['creation_date'] ?? 0,
        sortIndex = json["sort_index"] ?? 0;

  Map<String, dynamic> toJson() => {
        'id': uuid,
        'emoji': emoji,
        'note': note,
        'day_index': dayIndex,
        'sort_index': sortIndex,
        'creation_date': creationDate,
      };
}
