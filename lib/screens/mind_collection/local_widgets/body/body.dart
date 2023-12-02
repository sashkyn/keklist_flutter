part of '../../mind_collection_screen.dart';

class _Body extends StatelessWidget {
  final bool isSearching;
  final bool isDemoMode;
  final List<Mind> searchResults;
  final Function hideKeyboard;
  final Function onTapToDay;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Function getNowDayIndex;
  final Random demoModeRandom;
  final Map<int, List<Mind>> mindsByDayIndex;

  const _Body({
    required this.isSearching,
    required this.isDemoMode,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.getNowDayIndex,
    required this.demoModeRandom,
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

    final Widget scrollablePositionedList = ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(top: 16.0),
      itemCount: 99999999999,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (BuildContext context, int groupDayIndex) {
        final List<Mind> minds = [];
        if (isDemoMode) {
          minds.addAll(
            List.generate(
              16,
              (index) {
                final String randomEmoji = KeklistConstants
                    .demoModeEmojiList[demoModeRandom.nextInt(KeklistConstants.demoModeEmojiList.length - 1)];
                return Mind(
                    emoji: randomEmoji,
                    creationDate: DateTime.now(),
                    note: '',
                    dayIndex: 0,
                    id: const Uuid().v4(),
                    sortIndex: 0,
                    rootId: null);
              },
            ).toList(),
          );
        } else {
          final List<Mind> mindsOfDay = mindsByDayIndex[groupDayIndex] ?? [];
          minds.addAll(mindsOfDay);
        }

        final bool isToday = groupDayIndex == getNowDayIndex();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18.0),
            Text(
              _formatter.format(MindUtils.getDateFromIndex(groupDayIndex)),
              style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
            ),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () {
                onTapToDay(
                  groupDayIndex: groupDayIndex,
                  initialError: null,
                );
              },
              child: RoundedContainer(
                border: isToday
                    ? Border.all(
                        color: Colors.black.withOpacity(0.3),
                        width: 2.0,
                      )
                    : null,
                child: Container(
                  constraints: BoxConstraints.tightForFinite(width: MediaQuery.of(context).size.width - 16.0),
                  child: BoolWidget(
                    condition: minds.isEmpty,
                    trueChild: () {
                      if (groupDayIndex < getNowDayIndex()) {
                        return MindCollectionEmptyDayWidget.past();
                      } else if (groupDayIndex > getNowDayIndex()) {
                        return MindCollectionEmptyDayWidget.future();
                      } else {
                        return MindCollectionEmptyDayWidget.present();
                      }
                    }(),
                    falseChild: Container(
                      constraints: BoxConstraints.tightForFinite(width: MediaQuery.of(context).size.width - 16.0),
                      child: MindRowsWidget(minds: minds),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );

    return GestureDetector(
      onPanDown: (_) => hideKeyboard(),
      child: BoolWidget(
        condition: isDemoMode,
        trueChild: Blur(
          blur: 3,
          blurColor: Colors.transparent,
          colorOpacity: 0.2,
          child: scrollablePositionedList,
        ),
        falseChild: scrollablePositionedList,
      ),
    );
  }
}
