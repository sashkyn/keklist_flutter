import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keklist/services/entities/mind.dart';

class MindBulletWidget extends StatelessWidget {
  final Mind mind;
  final VoidCallback? onOptions;

  const MindBulletWidget({
    super.key,
    required this.mind,
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
            mind.emoji,
            style: const TextStyle(fontSize: 25.0),
          ),
          const Gap(8.0),
          Flexible(
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                mind.note,
                maxLines: null,
                style: const TextStyle(fontSize: 15.0),
              ),
            ),
          ),
          const Gap(10.0),
        ],
      ),
    );
  }
}
