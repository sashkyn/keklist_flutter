import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/helpers/extensions/dispose_bag.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/insights/widgets/insights_pie_widget.dart';
import 'package:keklist/screens/insights/widgets/insights_random_mind_widget.dart';
import 'package:keklist/screens/insights/widgets/insights_today_minds_widget.dart';
import 'package:keklist/screens/insights/widgets/insights_top_chart.dart';
import 'package:keklist/screens/mind_collection/local_widgets/mind_rows_widget.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/rounded_container.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with DisposeBag {
  final List<Mind> _minds = [];

  @override
  void initState() {
    super.initState();

    context.read<MindBloc>().stream.listen((state) {
      if (state is MindList) {
        setState(() {
          _minds
            ..clear()
            ..addAll(state.values);
        });
      }
    }).disposed(by: this);
  }

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
          final int crossAxisCellCount = constraints.maxWidth > 600 ? 2 : 3;
          return SingleChildScrollView(
            child: StaggeredGrid.count(
              axisDirection: AxisDirection.down,
              crossAxisCount: crossAxisCount,
              children: [
                StaggeredGridTile.fit(
                  crossAxisCellCount: crossAxisCellCount,
                  child: InsightsTodayMindsWidget(
                    todayMinds: MindUtils.findTodayMinds(allMinds: _minds),
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: crossAxisCellCount,
                  child: InsightsRandomMindWidget(allMinds: _minds),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: crossAxisCellCount,
                  child: InsightsPieWidget(allMinds: _minds),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: crossAxisCellCount,
                  child: InsightsTopChartWidget(allMinds: _minds),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
