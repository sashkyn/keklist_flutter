import 'package:flutter/material.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/rounded_container.dart';
import 'package:rememoji/widgets/rounded_text.dart';

class MindMessageWidget extends StatelessWidget {
  final Mind mind;
  final int? childCount;
  final VoidCallback? onOptions;

  const MindMessageWidget({
    Key? key,
    required this.mind,
    required this.onOptions,
    required this.childCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      border: null,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    mind.emoji,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    mind.note,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (onOptions != null) ...{
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: onOptions,
              ),
            ),
          },
          if (childCount != null && childCount != 0) ...{
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: RoundedText(
                  text: '$childCount',
                  textColor: Colors.white,
                  backgroundColor: Colors.lightGreen,
                  borderColor: Colors.white,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
