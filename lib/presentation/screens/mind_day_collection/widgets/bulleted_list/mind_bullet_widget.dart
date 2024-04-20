import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MindBulletWidget extends StatelessWidget {
  final MindBulletModel model;

  const MindBulletWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Gap(10.0),
        Text(
          model.emoji,
          style: const TextStyle(fontSize: 25.0),
        ),
        const Gap(16.0),
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
        const Gap(10.0),
      ],
    );
}

final class MindBulletModel {
  final String entityId;
  final String emoji;
  final String text;

  const MindBulletModel({
    required this.entityId,
    required this.emoji,
    required this.text,
  });
}
