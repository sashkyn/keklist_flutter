import 'dart:async';

import 'package:keklist/domain/services/entities/mind.dart';

// TODO: remove from here isUploadedToServer and etc.
// TODO: merge with service

abstract class MindRepository {
  Iterable<Mind> get values;
  Stream<Iterable<Mind>> get stream;
  FutureOr<Iterable<Mind>> obtainMinds();
  FutureOr<Mind> createMind({required Mind mind, required bool isUploadedToServer});
  FutureOr<void> createMinds({required Iterable<Mind> minds, required bool isUploadedToServer});
  FutureOr<Mind?> obtainMind({required String mindId});
  FutureOr<Iterable<Mind>> obtainMindsWhere(bool Function(Mind) where);
  FutureOr<Iterable<Mind>> obtainNotUploadedToServerMinds();
  FutureOr<void> updateMind({required Mind mind, required bool isUploadedToServer});
  FutureOr<void> updateUploadedOnServerMind({required String mindId, required bool isUploadedToServer});
  FutureOr<void> updateUploadedOnServerMinds({required Iterable<Mind> minds, required bool isUploadedToServer});
  FutureOr<void> updateMinds({required Iterable<Mind> minds, required bool isUploadedToServer});
  FutureOr<void> deleteMind({required String mindId});
  FutureOr<void> deleteMinds();
  FutureOr<void> deleteMindsWhere(bool Function(Mind) where);  
}
