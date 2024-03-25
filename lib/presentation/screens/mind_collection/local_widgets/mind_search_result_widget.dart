import 'package:flutter/material.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/domain/services/entities/mind.dart';

class MindSearchResultListWidget extends StatelessWidget {
  final List<Mind> results;
  final Function(Mind) onTapToMind;

  const MindSearchResultListWidget({
    super.key,
    required this.results,
    required this.onTapToMind,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            ),
          );
        } else {
          if (results.isEmpty) {
            return const SizedBox.shrink();
          } else {
            final Mind mind = results[index - 1];
            return GestureDetector(
              onTap: onTapToMind(mind),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MindMessageWidget(
                  mind: mind,
                  onOptions: null,
                  children: const [],
                ),
              ),
            );
          }
        }
      },
    );
  }
}
