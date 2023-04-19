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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10.0,
              offset: const Offset(1.0, 1.0),
            ),
          ],
        ),
        child: Container(
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
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
