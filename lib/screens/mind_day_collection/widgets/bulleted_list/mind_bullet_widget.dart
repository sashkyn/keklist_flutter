import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            width: 8.0,
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 20.0),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              text,
              maxLines: null,
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: onOptions,
          ),
        ],
      ),
    );
  }
}
