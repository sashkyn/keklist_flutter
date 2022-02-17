import 'entities/mark.dart';

abstract class IStorage {
  Future<void> connect();
  Future<void> addMark(Mark mark);
  Future<void> removeMarkFromDay(String id);
  Future<void> save({required List<Mark> list});
  Future<List<Mark>> getMarks();
}
