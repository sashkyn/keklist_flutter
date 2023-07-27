import 'package:flutter/material.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/rounded_container.dart';

class MindMessageWidget extends StatelessWidget {
  final Mind mind;

  const MindMessageWidget({
    Key? key,
    required this.mind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      border: null,
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
    );
  }
}
