import 'package:flutter/material.dart';
import 'package:rememoji/services/entities/mind.dart';

class MindMessageWidget extends StatelessWidget {
  final Mind mind;

  const MindMessageWidget({
    Key? key,
    required this.mind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            mind.emoji,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            mind.note,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
