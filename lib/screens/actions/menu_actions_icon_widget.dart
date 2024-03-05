import 'package:flutter/material.dart';
import 'package:keklist/screens/actions/action_model.dart';

final class MenuActionsIconWidget extends StatelessWidget {
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
      // style: MenuStyle(
      //   backgroundColor: MaterialStateProperty.resolveWith<Color?>(
      //     (states) => Theme.of(context).scaffoldBackgroundColor,
      //   ),
      //   elevation: MaterialStateProperty.resolveWith<double?>((states) => 8.0),
      //   shape: MaterialStateProperty.resolveWith<OutlinedBorder?>(
      //     (states) => RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8.0),
      //     ),
      //   ),
      // ),
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: action.icon,
          tooltip: action.title,
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
                onMenuAction(action);
              },
            ),
          )
          .toList(),
    );
  }
}
