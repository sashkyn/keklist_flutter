import 'package:flutter/material.dart';
import 'package:keklist/presentation/core/widgets/mind_widget.dart';

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

  factory MindCollectionEmptyDayWidget.noMinds() {
    return const MindCollectionEmptyDayWidget(
      emoji: '😔',
      text: 'No minds for day',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        MindWidget.sized(
          item: emoji,
          size: MindSize.medium,
          isHighlighted: false,
          badge: null,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
