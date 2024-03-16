import 'package:keklist/domain/services/entities/mind.dart';

abstract class MindRepository {
  Stream<List<Mind>> get stream;
  Future<List<Mind>> obtainMinds();
  Future<void> createMind({required Mind mind, required bool isUploadedToServer});
  Future<Mind?> obtainMind({required String mindId});
  Future<List<Mind>> obtainMindsWhere(bool Function(Mind) where);
  Future<List<Mind>> obtainNotUploadedToServerMinds();
  Future<void> updateMind({required Mind mind, required bool isUploadedToServer});
  Future<void> updateUploadedOnServerMind({required String mindId, required bool isUploadedToServer});
  Future<void> updateUploadedOnServerMinds({required List<Mind> minds, required bool isUploadedToServer});
  Future<void> updateMinds({required List<Mind> minds, required bool isUploadedToServer});
  Future<void> deleteMind({required String mindId});
  Future<void> deleteMinds();
  Future<void> deleteMindsWhere(bool Function(Mind) where);
}
