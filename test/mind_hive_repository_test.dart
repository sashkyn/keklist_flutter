import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/message_repository/mind/mind_object.dart';
import 'package:keklist/domain/repositories/mind_repository/mind_hive_repository.dart';
import 'package:keklist/domain/repositories/mind_repository/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    Hive.init('.');
    Hive.registerAdapter<MindObject>(MindObjectAdapter());
  });
  test(
    'createMind: creates mind correctly',
    () async {
      // Given
      final hiveBox = await Hive.openBox<MindObject>(HiveConstants.mindBoxName);
      final MindRepository repository = MindHiveRepository(mindBox: hiveBox);

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
      expect(
        minds.contains(mind),
        true,
      );
    },
  );
}
