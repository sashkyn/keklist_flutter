import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/mind_widget.dart';
import 'package:rememoji/widgets/rounded_circle.dart';

// TODO: Переделать на график
// По количеству символов
// По частоте использования
// За конкретный день - сегодня, вчера, конкретный день
// За период - неделя, 2 недели, месяц, год, конкертный период
// Добавить переключатель
// Добавить тайтл
// Цвета - более приятно рандомизированные
// Добавить разделители в пай график

class InsightsPieWidget extends StatelessWidget {
  final List<Mind> minds;

  const InsightsPieWidget({
    super.key,
    required this.minds,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          sections: getSectionData(),
          centerSpaceRadius: 0,
          sectionsSpace: 0,
          startDegreeOffset: 0,
        ),
      ),
    );
  }

  List<PieChartSectionData> getSectionData() {
    final List<Mind> todayMinds = MindUtils.findTodayMinds(allMinds: minds);

    return todayMinds.map(
      (mind) {
        return PieChartSectionData(
          color: _getRandomColor(),
          value: mind.note.length.toDouble(),
          title: '',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
          badgeWidget: RoundedCircle(
            child: MindWidget.justEmoji(
              emoji: mind.emoji,
              size: 40,
            ),
          ),
          badgePositionPercentageOffset: 1.4,
        );
      },
    ).toList();
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
