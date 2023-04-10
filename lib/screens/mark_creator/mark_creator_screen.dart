import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/typealiases.dart';
import 'package:zenmode/widgets/mind_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MarkCreatorScreen extends StatefulWidget {
  final ArgumentCallback<CreateMindData> onCreate;

  const MarkCreatorScreen({
    Key? key,
    required this.onCreate,
  }) : super(key: key);

  @override
  MarkCreatorScreenState createState() => MarkCreatorScreenState();
}

class MarkCreatorScreenState extends State<MarkCreatorScreen> {
  String _emoji = Emoji.all().first.char;
  String _text = '';

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _text = _textEditingController.text;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          MindWidget(
            item: _emoji,
            isHighlighted: true,
            onTap: () {
              _showMarkPickerScreen(onSelect: (emoji) {
                setState(() {
                  _emoji = emoji;
                });
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            autofocus: false,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            controller: _textEditingController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: 'Create new mind...',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pop();
          final CreateMindData data = CreateMindData(
            emoji: _emoji,
            text: _text,
          );
          widget.onCreate(data);
        },
      ),
    );
  }

  void _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkPickerScreen(onSelect: onSelect),
    );
  }
}

class CreateMindData {
  final String text;
  final String emoji;

  const CreateMindData({
    required this.text,
    required this.emoji,
  });
}
