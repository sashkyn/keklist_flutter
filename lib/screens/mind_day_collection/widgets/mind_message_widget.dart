import 'package:flutter/material.dart';
import 'package:zenmode/services/entities/mind.dart';

class MindMessageWidget extends StatelessWidget {
  final Mind mind;

  const MindMessageWidget({
    Key? key,
    required this.mind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            mind.emoji,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            mind.note,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
