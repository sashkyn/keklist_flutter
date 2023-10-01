import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';
import 'package:rememoji/services/entities/mind.dart';

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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                    onTap: () => onTap(mind),
                    child: MindBulletWidget(
                      emoji: mind.emoji,
                      text: mind.note,
                      onOptions: () => onOptions(mind),
                    ).animate().fadeIn()),
              ],
            );
          }).toList() +
          [
            const Column(children: [SizedBox(height: 160.0)]),
          ],
    );
  }
}
