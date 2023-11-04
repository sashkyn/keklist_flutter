import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MindBulletWidget extends StatelessWidget {
  final String emoji;
  final String text;
  final VoidCallback? onOptions;

  const MindBulletWidget({
    super.key,
    required this.emoji,
    required this.text,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Gap(10.0),
          Text(
            emoji,
            style: const TextStyle(fontSize: 25.0),
          ),
          const Gap(8.0),
          Flexible(
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                text,
                maxLines: null,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          const Gap(10.0),
        ],
      ),
    );
  }
}
