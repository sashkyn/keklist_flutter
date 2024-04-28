import 'dart:async';

import '../entities/mind.dart';

abstract class MindService {
  Future<void> editMind({required Mind mind});
  Future<void> createMind(Mind mind);
  Future<void> deleteMind(String id);
  Future<void> addAllMinds({required Iterable<Mind> values});
  Future<Iterable<Mind>> getMindList();
  Future<void> deleteAccount();
  Future<void> deleteAllMinds();
  Future<void> deleteAllChildMinds({required String rootId});
}
