import 'package:flutter_test/flutter_test.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/services/entities/mind.dart';

void main() {
  test(
    'mySortedBy: sorted correctly',
    () {
      final List<Mind> unsortedMinds = [];
      unsortedMinds.add(
        const Mind(
          id: '1',
          note: 'Heh1',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 5,
          creationDate: 0,
        ),
      );
      unsortedMinds.add(
        const Mind(
          id: '1',
          note: 'Heh3',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 20,
          creationDate: 0,
        ),
      );
      unsortedMinds.add(
        const Mind(
          id: '1',
          note: 'Heh2',
          emoji: ' ',
          dayIndex: 0,
          sortIndex: 10,
          creationDate: 0,
        ),
      );

      expect(
        unsortedMinds.map((e) => e.sortIndex),
        [5, 20, 10],
      );

      final List<Mind> sortedList = unsortedMinds.mySortedBy((it) => it.sortIndex).toList();

      expect(
        sortedList.map((e) => e.sortIndex),
        [5, 10, 20],
      );
    },
  );
}
