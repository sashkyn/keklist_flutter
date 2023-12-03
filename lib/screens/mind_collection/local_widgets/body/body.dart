part of '../../mind_collection_screen.dart';

class _Body extends StatelessWidget {
  final bool isBlured;
  final bool isSearching;
  final List<Mind> searchResults;
  final VoidCallback hideKeyboard;
  final Function(int) onTapToDay;
  final List<Mind> Function(int) getMindByDayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Function getNowDayIndex;

  const _Body({
    required this.isBlured,
    required this.isSearching,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.getNowDayIndex,
    required this.getMindByDayIndex,
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
      itemBuilder: (_, int dayIndex) {
        final List<Mind> minds = getMindByDayIndex(dayIndex);

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
              child: RoundedContainer(
                border: isToday
                    ? Border.all(
                        color: Colors.black.withOpacity(0.4),
                        width: 2.0,
                      )
                    : null,
                child: BoolWidget(
                  condition: minds.isEmpty,
                  trueChild: () {
                    if (dayIndex < getNowDayIndex()) {
                      return MindCollectionEmptyDayWidget.past();
                    } else if (dayIndex > getNowDayIndex()) {
                      return MindCollectionEmptyDayWidget.future();
                    } else {
                      return MindCollectionEmptyDayWidget.present();
                    }
                  }(),
                  falseChild: MindRowsWidget(minds: minds),
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
        condition: isBlured,
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
