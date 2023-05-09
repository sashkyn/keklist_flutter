import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/rounded_container.dart';

// TODO: добавить дату
// TODO: возможность перехода на источник

class InsightsRandomMindWidget extends StatefulWidget {
  final List<Mind> allMinds;

  const InsightsRandomMindWidget({
    super.key,
    required this.allMinds,
  });

  @override
  State<InsightsRandomMindWidget> createState() => _InsightsRandomMindWidgetState();
}

class _InsightsRandomMindWidgetState extends State<InsightsRandomMindWidget> {
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    final Mind randomMind = widget.allMinds[_random.nextInt(widget.allMinds.length)];
    return GestureDetector(
      onDoubleTap: () {
        setState(() {});
      },
      child: RoundedContainer(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Thoughts out loud',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    randomMind.emoji,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    randomMind.note,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
