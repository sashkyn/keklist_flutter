import 'entities/mark.dart';

abstract class Storage {
  Future<void> addMark(Mark mark);
  Future<void> removeMarkFromDay(String id);
  Future<List<Mark>> getMarks();
}
