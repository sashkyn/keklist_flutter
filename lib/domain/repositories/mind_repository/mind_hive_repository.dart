import 'package:hive/hive.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/message_repository/mind/mind_object.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/repositories/mind_repository/mind_repository.dart';
import 'package:rxdart/rxdart.dart';

final class MindHiveRepository implements MindRepository {
  final Box<MindObject> _mindBox = Hive.box<MindObject>(HiveConstants.mindBoxName);
  Iterable<MindObject> get _mindObjects => _mindBox.values;

  @override
  Stream<List<Mind>> get stream => _mindBox
      .watch()
      .map((_) => _mindObjects.map((mindObject) => mindObject.toMind()).toList())
      .debounceTime(const Duration(milliseconds: 100));

  @override
  Future<void> createMind({required Mind mind, required bool isUploadedToServer}) {
    final MindObject object = mind.toObject(isUploadedToServer: isUploadedToServer);
    return _mindBox.put(mind.id, object);
  }

  @override
  Future<void> deleteMind({required String mindId}) {
    final MindObject? object = _mindBox.get(mindId);
    return object?.delete() ?? Future.value();
  }

  @override
  Future<Mind> obtainMind({required String mindId}) {
    final MindObject? object = _mindBox.get(mindId);
    return Future.value(object?.toMind());
  }

  @override
  Future<List<Mind>> obtainMinds() {
    final List<Mind> minds = _mindObjects.map((mindObject) => mindObject.toMind()).toList();
    return Future.value(minds);
  }

  @override
  Future<void> updateMind({required Mind mind, required bool isUploadedToServer}) {
    final bool isUploadedToServer = _mindBox.get(mind.id)?.isUploadedToServer ?? false;
    final MindObject object = mind.toObject(isUploadedToServer: isUploadedToServer);
    return _mindBox.put(mind.id, object);
  }

  @override
  Future<void> updateUploadedOnServerMind({required String mindId, required bool isUploadedToServer}) {
    final MindObject? object = _mindBox.get(mindId);
    object?.isUploadedToServer = isUploadedToServer;
    return object?.save() ?? Future.value();
  }

  @override
  Future<void> updateMinds({required List<Mind> minds, required bool isUploadedToServer}) {
    final Map<String, MindObject> mindEntries = Map.fromEntries(
      minds.map(
        (mind) => MapEntry(
          mind.id,
          mind.toObject(isUploadedToServer: isUploadedToServer),
        ),
      ),
    );
    return _mindBox.putAll(mindEntries);
  }

  @override
  Future<void> updateUploadedOnServerMinds({required List<Mind> minds, required bool isUploadedToServer}) {
    final List<MindObject> mindObjects =
        minds.map((mind) => mind.toObject(isUploadedToServer: isUploadedToServer)).toList();
    final Map<String, MindObject> mindEntries = Map.fromEntries(
      mindObjects.map(
        (mindObject) => MapEntry(
          mindObject.id,
          mindObject,
        ),
      ),
    );
    return _mindBox.putAll(mindEntries);
  }

  @override
  Future<List<Mind>> obtainMindsWhere(bool Function(Mind) where) {
    final List<Mind> minds = _mindObjects.map((mindObject) => mindObject.toMind()).where(where).toList();
    return Future.value(minds);
  }

  @override
  Future<List<Mind>> obtainNotUploadedToServerMinds() {
    final List<Mind> notUploadedMinds =
        _mindObjects.where((mindObject) => !mindObject.isUploadedToServer).map((mind) => mind.toMind()).toList();
    return Future.value(notUploadedMinds);
  }

  @override
  Future<void> deleteMindsWhere(bool Function(Mind) where) {
    final List<String> mindIds =
        _mindObjects.map((mindObject) => mindObject.toMind()).where(where).map((mind) => mind.id).toList();
    return _mindBox.deleteAll(mindIds);
  }

  @override
  Future<void> deleteMinds() {
    return _mindBox.clear();
  }
}
