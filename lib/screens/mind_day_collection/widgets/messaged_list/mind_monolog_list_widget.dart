import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/domain/services/entities/mind.dart';

final class MindMonologListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Map<String, List<Mind>>? mindIdsToChildren;
  final Function(Mind) onTap;
  final Widget? optionsWidget;

  const MindMonologListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.mindIdsToChildren,
    required this.optionsWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
          return StaggeredGrid.count(
            crossAxisCount: crossAxisCount,
            children: minds.map(
              (mind) {
                return StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => onTap(mind),
                      child: MindMessageWidget(
                        mind: mind,
                        children: mindIdsToChildren?[mind.id] ?? [],
                        optionsWidget: optionsWidget,
                      ).animate().fadeIn(),
                    ),
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}
