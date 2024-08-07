import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/widgets/rounded_container.dart';
import 'package:keklist/presentation/core/widgets/sensitive_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InsightsTopChartWidget extends StatelessWidget {
  final List<Mind> allMinds;

  const InsightsTopChartWidget({
    super.key,
    required this.allMinds,
  });

  @override
  Widget build(BuildContext context) {
    final HashMap<String, int> data = allMinds.map((mind) {
      return mind.emoji;
    }).fold(HashMap<String, int>(), (HashMap<String, int> map, emoji) {
      if (map.containsKey(emoji)) {
        map[emoji] = map[emoji]! + 1;
      } else {
        map[emoji] = 1;
      }
      return map;
    });
    final List<_MindData> chartData = data.entries
        .map(
          (entry) => _MindData(entry.key, entry.value),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RoundedContainer(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Top minds',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SensitiveWidget(
              child: SfCartesianChart(
                primaryYAxis: const CategoryAxis(
                  isVisible: false,
                  labelStyle: TextStyle(fontSize: 16.0),
                ),
                primaryXAxis: const CategoryAxis(
                  labelStyle: TextStyle(fontSize: 32.0),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<_MindData, String>(
                    dataSource: chartData.take(8).toList(),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                    xValueMapper: (_MindData mind, _) => mind.emoji,
                    yValueMapper: (_MindData mind, _) => mind.count,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MindData {
  _MindData(this.emoji, this.count);

  final String emoji;
  final int count;
}
