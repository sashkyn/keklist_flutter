import 'package:flutter/material.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';

class ActionsScreen extends StatelessWidget {
  final List<(ActionModel, Function())> actions;
  const ActionsScreen({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Wrap(
          children: actions
              .map(
                (action) => ListTile(
                  leading: action.$1.icon,
                  title: Text(
                    action.$1.title,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    action.$2.call();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
