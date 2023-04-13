import 'package:flutter/material.dart';
import 'package:rememoji/screens/mind_collection/widgets/my_table.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/mind_widget.dart';

class MindIconedListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Function(Mind) onTap;
  final Function(Mind) onLongTap;

  const MindIconedListWidget({
    super.key,
    required this.minds,
    required this.onTap,
    required this.onLongTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        MyTable(
          widgets: minds
              .map(
                (mind) => MindWidget.sized(
                  item: mind.emoji,
                  size: MindSize.large,
                  onTap: () => onTap(mind),
                  onLongTap: () => onLongTap(mind),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
