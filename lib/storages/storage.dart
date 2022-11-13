import 'dart:async';

import 'entities/mark.dart';

abstract class IStorage {
  FutureOr<void> addMark(Mark mark);
  FutureOr<void> removeMarkFromDay(String id);
  FutureOr<void> save({required List<Mark> list});
  FutureOr<List<Mark>> getMarks();
}
