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
    return BoolWidget(
      condition: !isSearching,
      falseChild: MindSearchResultListWidget(
        results: searchResults,
        onTapToMind: (mind) => () {
          hideKeyboard();
          onTapToDay(mind.dayIndex);
        },
      ),
      trueChild: GestureDetector(
        onPanDown: (_) => hideKeyboard(),
        child: ScrollablePositionedList.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: 99999999999,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (_, int dayIndex) {
            final List<Mind> minds = mindsByDayIndex[dayIndex]?.sortedBySortIndex() ?? [];
            // final List<Mind> minds = List.generate(
            //   Random().nextInt(50) + 1,
            //   (index) {
            //     final String randomEmoji = KeklistConstants.demoModeEmojiList[index];
            //     return Mind(
            //       emoji: randomEmoji,
            //       creationDate: DateTime.now(),
            //       note: '',
            //       dayIndex: 0,
            //       id: const Uuid().v4(),
            //       sortIndex: 0,
            //       rootId: null,
            //     );
            //   },
            // ).toList();
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
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
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
    );
  }
}
