import 'dart:async';

import 'entities/mark.dart';

abstract class IStorage {
  FutureOr<void> addMark(Mark mark);
  FutureOr<void> removeMark(String id);
  FutureOr<void> addAll({required List<Mark> list});
  FutureOr<List<Mark>> getMarks();
  FutureOr<void> reset();
}
