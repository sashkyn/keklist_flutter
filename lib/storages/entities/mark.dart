class Mark {
  final String uuid;
  final String emoji;
  final String note;
  final int dayIndex;

  Mark({
    required this.uuid,
    required this.note,
    required this.emoji,
    required this.dayIndex,
  });

  Mark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'];

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'emoji': emoji,
      'note': note,
      'day_index': dayIndex,
    };
  }
}
