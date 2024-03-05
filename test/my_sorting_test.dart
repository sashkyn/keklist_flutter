import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/services/entities/mind.dart';

void main() {
  test(
    'mySortedBy: sorted correctly',
    () {
      final List<Mind> unsortedMinds = [];
      unsortedMinds.add(
        Mind(
          id: '1',
          note: 'Heh1',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 5,
          creationDate: DateTime.now(),
          rootId: null,
        ),
      );
      unsortedMinds.add(
        Mind(
          id: '1',
          note: 'Heh3',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 20,
          creationDate: DateTime.now(),
          rootId: null,
        ),
      );
      unsortedMinds.add(
        Mind(
          id: '1',
          note: 'Heh2',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 10,
          creationDate: DateTime.now(),
          rootId: null,
        ),
      );

      expect(
        unsortedMinds.map((e) => e.sortIndex),
        [5, 20, 10],
      );

      final List<Mind> sortedList = unsortedMinds.sortedByFunction((it) => it.sortIndex);

      expect(
        sortedList.map((e) => e.sortIndex),
        [5, 10, 20],
      );
    },
  );
}
