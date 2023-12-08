import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/services/entities/mind.dart';

class MindMonologListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Map<String, List<Mind>>? mindIdsToChildren;
  final Function(Mind) onTap;
  final Function(Mind) onOptions;

  const MindMonologListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.onOptions,
    required this.mindIdsToChildren,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
        crossAxisCount: 1,
        children: minds.map((mind) {
          return StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => onTap(mind),
                child: MindMessageWidget(
                  mind: mind,
                  children: mindIdsToChildren?[mind.id] ?? [],
                  onOptions: () => onOptions(mind),
                ).animate().fadeIn(),
              ),
            ),
          );
        }).toList());
  }
}
