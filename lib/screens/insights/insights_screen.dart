import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/screens/insights/widgets/insights_pie_widget.dart';
import 'package:rememoji/screens/insights/widgets/insights_random_mind_widget.dart';
import 'package:rememoji/screens/insights/widgets/insights_top_chart.dart';
import 'package:rememoji/services/entities/mind.dart';

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
      appBar: AppBar(title: const Text('Insights')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InsightsRandomMindWidget(allMinds: _minds),
              InsightsPieWidget(allMinds: _minds),
              InsightsTopChartWidget(allMinds: _minds),
            ],
          ),
        ),
      ),
    );
  }
}
