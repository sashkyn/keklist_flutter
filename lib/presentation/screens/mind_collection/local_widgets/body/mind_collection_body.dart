part of '../../mind_collection_screen.dart';

final class _MindCollectionBody extends StatelessWidget {
  final bool isSearching;
  final List<Mind> searchResults;
  final VoidCallback hideKeyboard;
  final Function(int) onTapToDay;
  final Map<int, Iterable<Mind>> mindsByDayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Function getNowDayIndex;
  final bool shouldShowTitles;

  const _MindCollectionBody({
    required this.isSearching,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.getNowDayIndex,
    required this.mindsByDayIndex,
    required this.shouldShowTitles,
  });

  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');
  static final DateFormat _yearTitleFormatter = DateFormat.y();
  static final DateFormat _monthTitleFormatter = DateFormat.MMMM().addPattern('').addPattern('yy', '');

  @override
  Widget build(BuildContext context) {
    return BoolWidget(
      condition: !isSearching,
      trueChild: GestureDetector(
        onPanDown: (_) => hideKeyboard(),
        child: ScrollablePositionedList.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: 99999999999,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (_, int dayIndex) {
            final Iterable<Mind> minds = mindsByDayIndex[dayIndex]?.sortedBySortIndex() ?? [];
            final bool isToday = dayIndex == getNowDayIndex();
            final DateTime currentDayDateIndex = MindUtils.getDateFromDayIndex(dayIndex);
            final DateTime previousDayDateIndex = currentDayDateIndex.subtract(const Duration(days: 1));
            final String currentDayYearTitle = _yearTitleFormatter.format(currentDayDateIndex);
            final String previousDayYearTitle = _yearTitleFormatter.format(previousDayDateIndex);
            final String currentDayMonthTitle = _monthTitleFormatter.format(currentDayDateIndex);
            final String previousDayMonthTitle = _monthTitleFormatter.format(previousDayDateIndex);
            final int currentDayWeekNumber = _getWeekNumber(currentDayDateIndex);
            final int previousDayWeekNumber = _getWeekNumber(previousDayDateIndex);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: BoolWidget(
                    condition: shouldShowTitles,
                    trueChild: Column(
                      children: [
                        BoolWidget(
                          condition: currentDayYearTitle != previousDayYearTitle,
                          trueChild: Text(
                            currentDayYearTitle,
                            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          falseChild: const SizedBox.shrink(),
                        ),
                        BoolWidget(
                          condition: currentDayMonthTitle != previousDayMonthTitle,
                          trueChild: Text(
                            currentDayMonthTitle,
                            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          falseChild: const SizedBox.shrink(),
                        ),
                        BoolWidget(
                          condition: currentDayWeekNumber != previousDayWeekNumber,
                          trueChild: Text(
                            'Week ${_getWeekNumber(currentDayDateIndex)}',
                            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          falseChild: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    falseChild: const SizedBox.shrink(),
                  ),
                ),
                Text(
                  _formatter.format(currentDayDateIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
                ),
                const SizedBox(height: 4.0),
                GestureDetector(
                  onTap: () => onTapToDay(dayIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RoundedContainer(
                      border: isToday
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                              width: 2.0,
                            )
                          : null,
                      child: BoolWidget(
                        condition: minds.isEmpty,
                        trueChild: MindCollectionEmptyDayWidget.noMinds(),
                        falseChild: MindRowWidget(minds: minds),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
      falseChild: MindSearchResultListWidget(
        results: searchResults,
        onTapToMind: (mind) => () {
          hideKeyboard();
          onTapToDay(mind.dayIndex);
        },
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(firstDayOfYear).inDays;
    final int weekdayOfFirstDay = firstDayOfYear.weekday;
    final int weekNumber = ((dayOfYear + weekdayOfFirstDay) / 7).ceil();
    return weekNumber;
  }
}
