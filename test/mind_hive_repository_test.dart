import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/mind/mind_hive_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    Hive.init('.');
    Hive.registerAdapter<MindObject>(MindObjectAdapter());
  });
  test('stream values and saved values the same', () async {
    // Given
    final hiveBox = await Hive.openBox<MindObject>(HiveConstants.mindBoxName);
    final MindRepository repository = MindHiveRepository(box: hiveBox);
    final Mind mind = Mind(
      id: '1',
      note: 'Heh1',
      emoji: ' ',
      dayIndex: 0,
      sortIndex: 5,
      creationDate: DateTime.now(),
      rootId: null,
    );

    // When
    await repository.updateMinds(minds: [mind, mind, mind, mind], isUploadedToServer: false);
    repository.stream.listen((minds) {
      // Then
      expect(repository.values, minds);
    });
  });
  test(
    'mind is created',
    () async {
      // Given
      final hiveBox = await Hive.openBox<MindObject>(HiveConstants.mindBoxName);
      final MindRepository repository = MindHiveRepository(box: hiveBox);

      // When
      var mind = Mind(
        id: '1',
        note: 'Heh1',
        emoji: ' ',
        dayIndex: 0,
        sortIndex: 5,
        creationDate: DateTime.now(),
        rootId: null,
      );
      await repository.createMind(
        mind: mind,
        isUploadedToServer: false,
      );
      final minds = await repository.obtainMinds();

      // Then
      expect(minds.contains(mind), true);
    },
  );
}
