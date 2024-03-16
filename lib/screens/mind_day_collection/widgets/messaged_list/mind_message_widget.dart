import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_list_widget.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/core/widgets/rounded_container.dart';

final class MindMessageWidget extends StatelessWidget {
  final Mind mind;
  final List<Mind> children;
  final Widget? optionsWidget;

  const MindMessageWidget({
    super.key,
    required this.mind,
    required this.children,
    required this.optionsWidget,
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
              if (optionsWidget != null) ...{
                Align(
                  alignment: Alignment.topRight,
                  child: optionsWidget,
                ),
              },
            ],
          ),
          if (children.isNotEmpty) ...[
            Container(height: 0.3, color: Colors.grey[300]),
            const Gap(16.0),
            MindBulletListWidget(
              models: children
                  .sortedByFunction((it) => it.creationDate)
                  .map(
                    (mind) => MindBulletModel(
                      entityId: mind.id,
                      emoji: mind.emoji,
                      text: mind.note,
                    ),
                  )
                  .toList(),
              onLongPress: (String mindId) {
                // onOptions?.call(children.firstWhere((it) => it.id == mindId));
              },
            ),
            const SizedBox(height: 16.0),
          ]
        ],
      ),
    );
  }
}
