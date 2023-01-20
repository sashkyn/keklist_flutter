import 'dart:async';

import 'entities/mark.dart';

abstract class IStorage {
  FutureOr<void> addMark(Mind mark);
  FutureOr<void> removeMark(String id);
  FutureOr<void> addAll({required List<Mind> list});
  FutureOr<Iterable<Mind>> getMarks();
  FutureOr<void> reset();
}
