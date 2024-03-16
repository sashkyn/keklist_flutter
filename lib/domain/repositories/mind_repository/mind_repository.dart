import 'dart:async';

import 'package:keklist/domain/services/entities/mind.dart';

abstract class MindRepository {
  Stream<List<Mind>> get stream;
  FutureOr<List<Mind>> obtainMinds();
  FutureOr<void> createMind({required Mind mind, required bool isUploadedToServer});
  FutureOr<Mind?> obtainMind({required String mindId});
  FutureOr<List<Mind>> obtainMindsWhere(bool Function(Mind) where);
  FutureOr<List<Mind>> obtainNotUploadedToServerMinds();
  FutureOr<void> updateMind({required Mind mind, required bool isUploadedToServer});
  FutureOr<void> updateUploadedOnServerMind({required String mindId, required bool isUploadedToServer});
  FutureOr<void> updateUploadedOnServerMinds({required List<Mind> minds, required bool isUploadedToServer});
  FutureOr<void> updateMinds({required List<Mind> minds, required bool isUploadedToServer});
  FutureOr<void> deleteMind({required String mindId});
  FutureOr<void> deleteMinds();
  FutureOr<void> deleteMindsWhere(bool Function(Mind) where);
}
