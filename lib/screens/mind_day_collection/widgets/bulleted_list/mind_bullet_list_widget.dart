import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';
import 'package:keklist/services/entities/mind.dart';

class MindBulletListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Function(Mind) onTap;
  final Function(Mind) onOptions;

  const MindBulletListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: minds.map((mind) {
        return GestureDetector(
          onTap: () => onTap(mind),
          onLongPress: () => onOptions(mind),
          child: MindBulletWidget(
            mind: mind,
            onOptions: () => onOptions(mind),
          ),
        );
      }).toList(),
    ).animate().fadeIn();
  }
}
