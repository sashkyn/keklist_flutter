import 'package:flutter/material.dart';

import '../services/entities/mind.dart';

class TextFieldAlert extends StatefulWidget {
  final String title;
  final String initialText;

  const TextFieldAlert({
    super.key,
    required this.initialText,
    required this.title,
  });

  @override
  TextFieldAlertState createState() => TextFieldAlertState();
}

class TextFieldAlertState extends State<TextFieldAlert> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit mind'),
      content: TextField(controller: _textEditingController),
      actions: <Widget>[
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            Navigator.of(context).pop(_textEditingController.text);
          },
        ),
      ],
    );
  }
}

extension ShowEditMindAlert on State {
  Future<String?> showEditMindAlert({required Mind mind}) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => TextFieldAlert(
        title: 'Edit mind - ${mind.emoji}',
        initialText: mind.note,
      ),
    );
  }
}
