part of '../../mind_collection_screen.dart';

class _Body extends StatelessWidget {
  final bool isSearching;
  final List<Mind> searchResults;
  final VoidCallback hideKeyboard;
  final Function(int) onTapToDay;
  final Map<int, List<Mind>> mindsByDayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Function getNowDayIndex;

  const _Body({
    required this.isSearching,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.getNowDayIndex,
    required this.mindsByDayIndex,
  });

  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');

  @override
  Widget build(BuildContext context) {
    // TODO: extract searching widget
    if (isSearching) {
      return MindSearchResultListWidget(
        results: searchResults,
        onPanDown: () => hideKeyboard(),
      );
    }

    return GestureDetector(
      onPanDown: (_) => hideKeyboard(),
      child: ScrollablePositionedList.builder(
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: 99999999999,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (_, int dayIndex) {
          final List<Mind> minds = mindsByDayIndex[dayIndex] ?? [];

          final bool isToday = dayIndex == getNowDayIndex();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18.0),
              Text(
                _formatter.format(MindUtils.getDateFromIndex(dayIndex)),
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
                            color: Colors.black.withOpacity(0.4),
                            width: 2.0,
                          )
                        : null,
                    child: BoolWidget(
                      condition: minds.isEmpty,
                      trueChild: BoolWidget(
                        condition: dayIndex < getNowDayIndex(),
                        trueChild: MindCollectionEmptyDayWidget.past(),
                        falseChild: BoolWidget(
                          condition: dayIndex > getNowDayIndex(),
                          trueChild: MindCollectionEmptyDayWidget.future(),
                          falseChild: MindCollectionEmptyDayWidget.present(),
                        ),
                      ),
                      falseChild: MindRowsWidget(minds: minds),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
