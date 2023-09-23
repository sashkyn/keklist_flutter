import 'package:rememoji/services/entities/mind.dart';

class MindUtils {
  static const int millisecondsInDay = 1000 * 60 * 60 * 24;

  static int getDayIndex({required DateTime from}) =>
      (from.millisecondsSinceEpoch + from.timeZoneOffset.inMilliseconds) ~/ millisecondsInDay;

  static int getTodayIndex() => MindUtils.getDayIndex(from: DateTime.now());

  static DateTime getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(millisecondsInDay * index);

  static List<Mind> findMindsByDayIndex({
    required int dayIndex,
    required Iterable<Mind> allMinds,
  }) =>
      allMinds
          .where((item) => dayIndex == item.dayIndex)
          .where((item) => item.rootId == null)
          .mySortedBy((it) => it.sortIndex)
          .toList();

  static List<Mind> findTodayMinds({required List<Mind> allMinds}) {
    return findMindsByDayIndex(
      dayIndex: getTodayIndex(),
      allMinds: allMinds,
    );
  }

  static List<Mind> findMindsByRootId({
    required String rootId,
    required Iterable<Mind> allMinds,
  }) =>
      allMinds.where((item) => rootId == item.rootId).mySortedBy((it) => it.sortIndex).toList();

  static List<Mind> findYesterdayMinds({required List<Mind> allMinds}) {
    final int yesterdayIndex = MindUtils.getDayIndex(from: DateTime.now()) - 1;
    return findMindsByDayIndex(
      dayIndex: yesterdayIndex,
      allMinds: allMinds,
    );
  }

  static List<Mind> findThisWeekMinds({required List<Mind> allMinds}) {
    final int todayIndex = MindUtils.getDayIndex(from: DateTime.now());
    final int weekAgoIndex = todayIndex - 7;
    return allMinds.where((item) => item.dayIndex >= weekAgoIndex && item.dayIndex <= todayIndex).toList();
  }

  static List<Mind> findThisMonthMinds({required List<Mind> allMinds}) {
    final int todayIndex = MindUtils.getDayIndex(from: DateTime.now());
    final int monthAgoIndex = todayIndex - 30;
    return allMinds.where((item) => item.dayIndex >= monthAgoIndex && item.dayIndex <= todayIndex).toList();
  }

  static List<Mind> findThisYearMinds({required List<Mind> allMinds}) {
    final int todayIndex = MindUtils.getDayIndex(from: DateTime.now());
    final int yearAgoIndex = todayIndex - 365;
    return allMinds.where((item) => item.dayIndex >= yearAgoIndex && item.dayIndex <= todayIndex).toList();
  }

  static List<Mind> findMindsByEmoji({
    required String emoji,
    required Iterable<Mind> allMinds,
  }) =>
      allMinds.where((item) => emoji == item.emoji).mySortedBy((it) => it.sortIndex).toList();
}

// NOTE: Sorted by.

extension ListIterable<E> on Iterable<E> {
  Iterable<E> mySortedBy(Comparable Function(E e) key) => toList()
    ..sort(
      (a, b) => key(a).compareTo(key(b)),
    );
}
