import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:rememoji/services/entities/mind.dart';

class MindMonologListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Map<String, int>? mindIdsToChildCount;
  final Function(Mind) onTap;
  final Function(Mind) onOptions;

  const MindMonologListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.onOptions,
    required this.mindIdsToChildCount,
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
                    child: MindMessageWidget(
                      mind: mind,
                      childCount: mindIdsToChildCount?[mind.id],
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
