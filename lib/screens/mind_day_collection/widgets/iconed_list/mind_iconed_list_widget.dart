import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/screens/mind_collection/widgets/my_table.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/mind_widget.dart';

class MindIconedListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Map<String, int>? mindIdsToChildCount;
  final Function(Mind) onTap;
  final Function(Mind) onLongTap;

  const MindIconedListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.onLongTap,
    required this.mindIdsToChildCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        MyTable(
          widgets: minds
              .map(
                (mind) => MindWidget.sized(
                  item: mind.emoji,
                  size: MindSize.large,
                  onTap: () => onTap(mind),
                  onLongTap: () => onLongTap(mind),
                  isHighlighted: mind.note.isNotEmpty,
                  badge: _obtainBadgeText(mind),
                ).animate().fadeIn(),
              )
              .toList(),
        ),
      ],
    );
  }

  String? _obtainBadgeText(Mind mind) {
    final int? count = mindIdsToChildCount?[mind.id];
    if (count == null || count == 0) {
      return null;
    }
    return '${mindIdsToChildCount?[mind.id]}';
  }
}
