class MindUtils {
  static const int millisecondsInDay = 1000 * 60 * 60 * 24;

  static int getDayIndex({required DateTime from}) =>
      (from.millisecondsSinceEpoch + from.timeZoneOffset.inMilliseconds) ~/ millisecondsInDay;

  static DateTime getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(millisecondsInDay * index);
}
