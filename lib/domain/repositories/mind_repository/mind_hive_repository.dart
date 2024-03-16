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
  FutureOr<void> createMind({required Mind mind, required bool isUploadedToServer}) async {
    final Stopwatch stopwatch = _measureStart();
    final MindObject object = mind.toObject(isUploadedToServer: isUploadedToServer);
    await _mindBox.put(mind.id, object);
    _measureStop(stopwatch, 'createMind');
  }

  @override
  FutureOr<void> deleteMind({required String mindId}) {
    final Stopwatch stopwatch = _measureStart();
    final MindObject? object = _mindBox.get(mindId);
    object?.delete();
    _measureStop(stopwatch, 'deleteMind');
  }

  @override
  FutureOr<Mind?> obtainMind({required String mindId}) {
    final Stopwatch stopwatch = _measureStart();
    final MindObject? object = _mindBox.get(mindId);
    _measureStop(stopwatch, 'obtainMind');
    return object?.toMind();
  }

  @override
  FutureOr<List<Mind>> obtainMinds() {
    final Stopwatch stopwatch = _measureStart();
    final List<Mind> minds = _mindObjects.map((mindObject) => mindObject.toMind()).toList();
    _measureStop(stopwatch, 'obtainMinds');
    return minds;
  }

  @override
  FutureOr<void> updateMind({required Mind mind, required bool isUploadedToServer}) {
    final Stopwatch stopwatch = _measureStart();
    final bool isUploadedToServer = _mindBox.get(mind.id)?.isUploadedToServer ?? false;
    final MindObject object = mind.toObject(isUploadedToServer: isUploadedToServer);
    _measureStop(stopwatch, 'updateMind');
    return _mindBox.put(mind.id, object);
  }

  @override
  FutureOr<void> updateUploadedOnServerMind({required String mindId, required bool isUploadedToServer}) async {
    final Stopwatch stopwatch = _measureStart();
    final MindObject? object = _mindBox.get(mindId);
    object?.isUploadedToServer = isUploadedToServer;
    await object?.save();
    _measureStop(stopwatch, 'updateUploadedOnServerMind');
  }

  @override
  FutureOr<void> updateMinds({required List<Mind> minds, required bool isUploadedToServer}) async {
    final mindEntries = {for (final mind in minds) mind.id: mind.toObject(isUploadedToServer: isUploadedToServer)};
    final Stopwatch stopwatch = _measureStart();
    await _mindBox.putAll(mindEntries);
    _measureStop(stopwatch, 'updateMinds - putAll');
  }

  @override
  FutureOr<void> updateUploadedOnServerMinds({required List<Mind> minds, required bool isUploadedToServer}) async {
    final Stopwatch stopwatch = _measureStart();
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
    await _mindBox.putAll(mindEntries);
    _measureStop(stopwatch, 'updateUploadedOnServerMinds');
  }

  @override
  FutureOr<List<Mind>> obtainMindsWhere(bool Function(Mind) where) {
    final Stopwatch stopwatch = _measureStart();
    final List<Mind> minds = _mindObjects.map((mindObject) => mindObject.toMind()).where(where).toList();
    _measureStop(stopwatch, 'obtainMindsWhere');
    return minds;
  }

  @override
  FutureOr<List<Mind>> obtainNotUploadedToServerMinds() {
    final Stopwatch stopwatch = _measureStart();
    final List<Mind> notUploadedMinds =
        _mindObjects.where((mindObject) => !mindObject.isUploadedToServer).map((mind) => mind.toMind()).toList();
    _measureStop(stopwatch, 'obtainNotUploadedToServerMinds');
    return notUploadedMinds;
  }

  @override
  FutureOr<void> deleteMindsWhere(bool Function(Mind) where) async {
    final Stopwatch stopwatch = _measureStart();
    final List<String> mindIds =
        _mindObjects.map((mindObject) => mindObject.toMind()).where(where).map((mind) => mind.id).toList();
    _measureStop(stopwatch, 'deleteMindsWhere');
    await _mindBox.deleteAll(mindIds);
  }

  @override
  FutureOr<void> deleteMinds() async {
    final Stopwatch stopwatch = _measureStart();
    await _mindBox.clear();
    _measureStop(stopwatch, 'deleteMinds');
  }

  Stopwatch _measureStart() {
    final stopwatch = Stopwatch()..start();
    return stopwatch;
  }

  _measureStop(Stopwatch stopwatch, String functionName) {
    print('$functionName measured: ${stopwatch.elapsed}');
    stopwatch.stop();
  }
}
