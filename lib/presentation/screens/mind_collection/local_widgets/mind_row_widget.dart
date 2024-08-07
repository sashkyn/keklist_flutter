import 'package:flutter/material.dart';
import 'package:keklist/domain/services/entities/mind.dart';

final class MindRowWidget extends StatelessWidget {
  final Iterable<Mind> minds;

  const MindRowWidget({super.key, required this.minds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            minds.map((e) => e.emoji).join(' '),
            style: const TextStyle(fontSize: 40.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
