import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MindBulletWidget extends StatelessWidget {
  final MindBulletModel model;

  const MindBulletWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (model.emojiLocation == MindBulletWidgetEmojiLocation.leading) ...[
          const Gap(10.0),
          Text(
            model.emoji,
            style: const TextStyle(fontSize: 25.0),
          ),
          const Gap(10.0),
        ],
        const Gap(8.0),
        Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              model.text,
              maxLines: null,
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
        ),
        if (model.emojiLocation == MindBulletWidgetEmojiLocation.trailing) ...[
          const Gap(10.0),
          Text(
            model.emoji,
            style: const TextStyle(fontSize: 25.0),
          ),
          const Gap(10.0),
        ],
      ],
    );
  }
}

final class MindBulletModel {
  final String entityId;
  final String emoji;
  final String text;
  final MindBulletWidgetEmojiLocation emojiLocation;

  const MindBulletModel({
    required this.entityId,
    required this.emoji,
    required this.text,
    required this.emojiLocation,
  });
}

enum MindBulletWidgetEmojiLocation { leading, trailing }
