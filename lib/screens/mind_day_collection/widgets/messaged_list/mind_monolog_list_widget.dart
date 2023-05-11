import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:rememoji/services/entities/mind.dart';

class MindMonologListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Function(Mind) onTap;

  const MindMonologListWidget({
    super.key,
    required this.minds,
    required this.onTap,
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
                  child: MindMessageWidget(mind: mind).animate().fadeIn()
                ),
              ],
            );
          }).toList() +
          [
            const Column(children: [SizedBox(height: 160.0)]),
          ],
    );
  }
}
