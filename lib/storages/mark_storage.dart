import 'package:localstorage/localstorage.dart';

class MarkStorage {
  final LocalStorage storage = LocalStorage('marks_storage.json');

  void add(MarkEntity mark) {
    final marks = getMarks();
    marks.add(mark);
    storage.setItem('marks', marks);
  }

  void remove(MarkEntity mark) {
    final marks = getMarks();
    marks.remove(mark);
    storage.setItem('marks', marks);
  }

  List<MarkEntity> getMarks() => storage.getItem('marks') ?? [];
}

class MarkEntity {
  final String emoji;
  final int indexDayFromStart1970;
  final String note;

  MarkEntity({
    required this.emoji,
    required this.indexDayFromStart1970,
    required this.note,
  });
}