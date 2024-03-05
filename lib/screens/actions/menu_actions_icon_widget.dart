import 'package:flutter/material.dart';
import 'package:keklist/screens/actions/action_model.dart';

class MenuActionsIconWidget extends StatelessWidget {
  final ActionModel action;
  final List<ActionModel> menuActions;
  final Function(ActionModel) onMenuAction;

  const MenuActionsIconWidget({
    super.key,
    required this.menuActions,
    required this.action,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.read_more),
          tooltip: 'Extra actions',
        );
      },
      menuChildren: menuActions
          .map(
            (action) => ListTile(
              leading: action.icon,
              title: Text(
                action.title,
                style: const TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onMenuAction(action);
              },
            ),
          )
          .toList(),
    );
  }
}
