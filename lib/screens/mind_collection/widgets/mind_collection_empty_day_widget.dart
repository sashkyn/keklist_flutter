import 'package:flutter/material.dart';
import 'package:rememoji/widgets/mind_widget.dart';

class MindCollectionEmptyDayWidget extends StatelessWidget {
  final String emoji;
  final String text;

  const MindCollectionEmptyDayWidget({
    super.key,
    required this.emoji,
    required this.text,
  });

  factory MindCollectionEmptyDayWidget.past() {
    return const MindCollectionEmptyDayWidget(
      emoji: '📜',
      text: 'Yesterday is history',
    );
  }

  factory MindCollectionEmptyDayWidget.present() {
    return const MindCollectionEmptyDayWidget(
      emoji: '⏳',
      text: 'Now',
    );
  }

  factory MindCollectionEmptyDayWidget.future() {
    return const MindCollectionEmptyDayWidget(
      emoji: '🔮',
      text: 'Tomorrow is a mystery',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        MindWidget.sized(
          item: emoji,
          size: MindSize.large,
          isHighlighted: false,
          badge: null,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(color: Colors.black.withOpacity(0.3)),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
