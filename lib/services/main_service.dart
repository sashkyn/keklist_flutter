import 'dart:async';

import 'entities/mind.dart';

abstract class MainService {
  Future<void> edit({required Mind mind});
  Future<void> addMind(Mind mind);
  Future<void> deleteMind(String id);
  Future<void> addAllMinds({required List<Mind> list});
  Future<Iterable<Mind>> getMindList();
  Future<void> deleteAccount();
  Future<void> deleteAllMinds();
}
