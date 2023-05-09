import 'dart:async';

import 'entities/mind.dart';

abstract class MainService {
  FutureOr<void> editMindEmoji({required String mindId, required String newEmoji});
  FutureOr<void> editMindNote({required String mindId, required String newNote});
  FutureOr<void> edit({required Mind mind});
  FutureOr<void> addMind(Mind mind);
  FutureOr<void> deleteMind(String id);
  FutureOr<void> addAll({required List<Mind> list});
  FutureOr<Iterable<Mind>> getMindList();
  FutureOr<void> clearTempCache();
  FutureOr<void> deleteAccount();
  FutureOr<void> deleteAllMinds();
}
