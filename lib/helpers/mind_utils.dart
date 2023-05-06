import 'package:rememoji/services/entities/mind.dart';

class MindUtils {
  static const int millisecondsInDay = 1000 * 60 * 60 * 24;

  static int getDayIndex({required DateTime from}) =>
      (from.millisecondsSinceEpoch + from.timeZoneOffset.inMilliseconds) ~/ millisecondsInDay;

  static DateTime getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(millisecondsInDay * index);

  static List<Mind> findMindsByDayIndex({
    required int dayIndex,
    required Iterable<Mind> allMinds,
  }) {
    return allMinds.where((item) => dayIndex == item.dayIndex).mySortedBy((it) => it.sortIndex).toList();
  }

  static List<Mind> findTodayMinds({required List<Mind> allMinds}) {
    final int todayDayIndex = MindUtils.getDayIndex(from: DateTime.now());
    return findMindsByDayIndex(
      dayIndex: todayDayIndex,
      allMinds: allMinds,
    );
  }
}

// NOTE: Sorted by.

extension ListIterable<E> on Iterable<E> {
  Iterable<E> mySortedBy(Comparable Function(E e) key) => toList()
    ..sort(
      (a, b) => key(a).compareTo(key(b)),
    );
}
