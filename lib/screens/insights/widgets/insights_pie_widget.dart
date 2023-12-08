import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/bool_widget.dart';
import 'package:keklist/widgets/rounded_container.dart';

// Improvements:
// Переключатель по количеству символов
// По частоте использования
// Цвета - более приятно рандомизированные - попросить ChatGPT сгенерить для каждого эмодзика
// Показывать за конкретный день лучше, а то получается как то много, либо поменять с пая на что нибудь еще

enum InsightsPieWidgetChoice {
  today(localizedTitle: 'Today', filter: MindUtils.findTodayMinds),
  yesterday(localizedTitle: 'Yesterday', filter: MindUtils.findYesterdayMinds),
  thisWeek(localizedTitle: 'This week', filter: MindUtils.findThisWeekMinds),
  thisMonth(localizedTitle: 'This Month', filter: MindUtils.findThisMonthMinds),
  thisYear(localizedTitle: 'This year', filter: MindUtils.findThisYearMinds);

  final String localizedTitle;
  final List<Mind> Function({required List<Mind> allMinds}) filter;

  const InsightsPieWidgetChoice({
    required this.localizedTitle,
    required this.filter,
  });
}

class InsightsPieWidget extends StatefulWidget {
  final List<Mind> allMinds;

  const InsightsPieWidget({
    super.key,
    required this.allMinds,
  });

  @override
  State<InsightsPieWidget> createState() => _InsightsPieWidgetState();
}

class _InsightsPieWidgetState extends State<InsightsPieWidget> {
  final List<InsightsPieWidgetChoice> _choices = [
    InsightsPieWidgetChoice.today,
    InsightsPieWidgetChoice.yesterday,
    InsightsPieWidgetChoice.thisWeek,
    InsightsPieWidgetChoice.thisMonth,
    InsightsPieWidgetChoice.thisYear,
  ];

  int _selectedChoiceIndex = 0;
  String? _selectedEmoji;

  @override
  Widget build(BuildContext context) {
    final List<Mind> choiceMinds = _choices[_selectedChoiceIndex].filter(allMinds: widget.allMinds);
    final HashMap<String, int> intervalChoiceMap = HashMap<String, int>();

    for (final Mind mind in choiceMinds) {
      // Это по длине текста
      if (intervalChoiceMap.containsKey(mind.emoji)) {
        intervalChoiceMap[mind.emoji] = intervalChoiceMap[mind.emoji]! + mind.note.length;
      } else {
        intervalChoiceMap[mind.emoji] = mind.note.length;
      }

      // Это по количеству использований
      // if (intervalChoiceMap.containsKey(mind.emoji)) {
      //   intervalChoiceMap[mind.emoji] = intervalChoiceMap[mind.emoji]! + 1;
      // } else {
      //   intervalChoiceMap[mind.emoji] = 1;
      // }
    }

    final List<PieChartSectionData> pieSections = _getPieSections(choiceMap: intervalChoiceMap);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RoundedContainer(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Spectrum',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _choices.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: MyChip(
                        isSelected: _selectedChoiceIndex == index,
                        onSelect: (bool selected) {
                          setState(() {
                            _selectedChoiceIndex = index;
                          });
                        },
                        selectedColor: Colors.black,
                        child: Text(
                          _choices[index].localizedTitle,
                          style: TextStyle(
                              fontSize: 14.0, color: _selectedChoiceIndex == index ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 0,
                  sectionsSpace: 0,
                  startDegreeOffset: 0,
                ),
                swapAnimationCurve: Curves.bounceInOut,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: intervalChoiceMap.entries.mySortedBy((e) => e.value, reversed: true).map(
                  (entry) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: MyChip(
                        isSelected: _selectedEmoji == entry.key,
                        onSelect: (bool selected) {
                          setState(() {
                            _selectedEmoji = entry.key;
                          });
                        },
                        selectedColor: _colorFromEmoji(entry.key),
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections({required HashMap<String, int> choiceMap}) {
    final int allValues = choiceMap.values.map((e) => e).fold<int>(0, (a, b) => a + b);
    return choiceMap.entries.mySortedBy((e) => e.value).map(
      (entry) {
        final currentValue = choiceMap.entries
            .where((element) => element.key == entry.key)
            .map((e) => e.value)
            .fold<int>(0, (a, b) => a + b);
        final double percentValue = 100 * currentValue / allValues;
        final bool shouldShowTitle = percentValue >= 6;

        final bool isSelected = entry.key == _selectedEmoji;
        return PieChartSectionData(
          color: _colorFromEmoji(entry.key),
          showTitle: shouldShowTitle,
          value: percentValue,
          title: percentValue.toStringAsFixed(1),
          radius: isSelected ? 170 : 150,
          titleStyle: TextStyle(
            fontSize: isSelected ? 17.0 : 15.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
          titlePositionPercentageOffset: 0.75,
          badgeWidget: BoolWidget(
            condition: shouldShowTitle,
            trueChild: Text(
              entry.key,
              style: const TextStyle(fontSize: 22.0),
            ),
            falseChild: const SizedBox.shrink(),
          ),
          badgePositionPercentageOffset: 0.50,
        );
      },
    )
        // .where((element) => element.showTitle)
        .toList();
  }

  Color _colorFromEmoji(String emoji) {
    final int codePoint = emoji.codeUnits.first + emoji.codeUnits.last;
    final Random random = Random(codePoint);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}

class MyChip extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  final Function(bool) onSelect;
  final Color selectedColor;

  const MyChip({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onSelect,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      showCheckmark: false,
      label: child,
      backgroundColor: isSelected ? selectedColor : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selectedColor,
          width: 2.0,
        ),
      ),
      selectedColor: selectedColor,
      selected: isSelected,
      onPressed: () {
        onSelect(isSelected);
      },
    );
  }
}
