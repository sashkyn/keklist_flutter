import 'package:flutter/material.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';

final class MindBulletListWidget extends StatelessWidget {
  final List<MindBulletModel> models;
  final Function(String) onTap;
  final Function(String) onLongPress;

  const MindBulletListWidget({
    super.key,
    required this.models,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: models.map((model) {
        return GestureDetector(
          onTap: () => onTap(model.entityId),
          onLongPress: () => onLongPress(model.entityId),
          child: MindBulletWidget(model: model),
        );
      }).toList(),
    );
  }
}
