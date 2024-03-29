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
import 'package:keklist/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/bool_widget.dart';

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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
            final int crossAxisCellCount = constraints.maxWidth > 600 ? 2 : 3;
            return BoolWidget(
              condition: _minds.isNotEmpty,
              falseChild: const SizedBox.shrink(),
              trueChild: SingleChildScrollView(
                child: StaggeredGrid.count(
                  axisDirection: AxisDirection.down,
                  crossAxisCount: crossAxisCount,
                  children: [
                    StaggeredGridTile.fit(
                      crossAxisCellCount: crossAxisCellCount,
                      child: GestureDetector(
                        onTap: () => _showDayCollectionScreen(groupDayIndex: MindUtils.getTodayIndex()),
                        child: InsightsTodayMindsWidget(
                          todayMinds: MindUtils.findTodayMinds(allMinds: _minds),
                        ),
                      ),
                    ),
                    StaggeredGridTile.fit(
                      crossAxisCellCount: crossAxisCellCount,
                      child: InsightsRandomMindWidget(
                        allMinds: _minds,
                        onTapToMind: (mind) => _showDayCollectionScreen(groupDayIndex: mind.dayIndex),
                      ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDayCollectionScreen({
    required int groupDayIndex,
    MindOperationError? initialError,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MindDayCollectionScreen(
          allMinds: _minds,
          initialDayIndex: groupDayIndex,
          initialError: initialError,
        ),
      ),
    );
  }
}
