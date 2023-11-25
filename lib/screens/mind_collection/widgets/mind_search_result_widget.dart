import 'package:flutter/material.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/services/entities/mind.dart';

class MindSearchResultListWidget extends StatelessWidget {
  final VoidCallback onPanDown;
  final List<Mind> results;

  const MindSearchResultListWidget({
    super.key,
    required this.results,
    required this.onPanDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => onPanDown(),
      child: ListView.builder(
        itemCount: results.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            if (results.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Text(
                'Found ${results.length} minds:',
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            );
          } else {
            if (results.isEmpty) {
              return const SizedBox.shrink();
            } else {
              final Mind mind = results[index - 1];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MindMessageWidget(
                  mind: mind,
                  onOptions: null,
                  children: const [],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
