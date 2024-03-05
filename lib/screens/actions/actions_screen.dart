import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keklist/screens/actions/action_model.dart';

// TODO: make dynamic height

class ActionsScreen extends StatelessWidget {
  final List<ActionModel> actions;
  final Function(ActionModel) onAction;

  const ActionsScreen({
    super.key,
    required this.actions,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Wrap(
          children: actions
              .map(
                (action) => ListTile(
                  leading: action.icon,
                  title: Text(
                    action.title,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAction(action);
                  },
                ),
              )
              .toList(),
        ),
      );
}
