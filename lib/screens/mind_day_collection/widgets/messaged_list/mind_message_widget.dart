import 'package:flutter/material.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/core/widgets/rounded_container.dart';

class MindMessageWidget extends StatelessWidget {
  final Mind mind;
  final VoidCallback? onOptions;
  final List<Mind> children;

  const MindMessageWidget({
    super.key,
    required this.mind,
    required this.onOptions,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      border: null,
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
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
              ),
              if (onOptions != null) ...{
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: onOptions,
                  ),
                ),
              },
            ],
          ),
          if (children.isNotEmpty) ...[
            Container(height: 0.3, color: Colors.grey[300]),
            const SizedBox(height: 16.0),
            Column(
              children: children
                  .mySortedBy((it) => it.creationDate)
                  .map(
                    (e) => MindBulletWidget(
                      model: MindBulletModel(
                        entityId: e.id,
                        emoji: e.emoji,
                        text: e.note,
                        emojiLocation: MindBulletWidgetEmojiLocation.leading,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16.0),
          ]
        ],
      ),
    );
  }
}
