class Mark {
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

  Mark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'],
        creationDate = json['creation_date'] ?? 0,
        sortIndex = json["sort_index"] ?? 0;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'note': note,
        'day_index': dayIndex,
        'sort_index': sortIndex,
        'creation_date': creationDate,
      };
}
