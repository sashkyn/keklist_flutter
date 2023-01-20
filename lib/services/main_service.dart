import 'dart:async';

import 'entities/mind.dart';

abstract class MainService {
  FutureOr<void> addMind(Mind mind);
  FutureOr<void> removeMind(String id);
  FutureOr<void> addAll({required List<Mind> list});
  FutureOr<Iterable<Mind>> getMindList();
  FutureOr<void> reset();
  FutureOr<void> deleteAccount();
}
