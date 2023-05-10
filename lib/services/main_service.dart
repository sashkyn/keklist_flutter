import 'dart:async';

import 'entities/mind.dart';

abstract class MainService {
  FutureOr<void> edit({required Mind mind});
  FutureOr<void> addMind(Mind mind);
  FutureOr<void> deleteMind(String id);
  FutureOr<void> addAllMinds({required List<Mind> list});
  FutureOr<Iterable<Mind>> getMindList();
  FutureOr<void> deleteAccount();
  FutureOr<void> deleteAllMinds();
}
