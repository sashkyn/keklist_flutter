import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/screens/mind_picker/mind_picker_screen.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/mind_widget.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MarkEditorScreen extends StatefulWidget {
  final Mind mind;

  const MarkEditorScreen({
    Key? key,
    required this.mind,
  }) : super(key: key);

  @override
  MarkEditorScreenState createState() => MarkEditorScreenState();
}

class MarkEditorScreenState extends State<MarkEditorScreen> {
  late String _emoji;
  late String _text;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _emoji = widget.mind.emoji;
    _text = widget.mind.note;

    _textEditingController.text = _text;
    _textEditingController.addListener(() {
      setState(() {
        _text = _textEditingController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          MindWidget(
            item: _emoji,
            onTap: () {
              _showMindPickerScreen(onSelect: (emoji) {
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
          _saveAndClose(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _saveAndClose(BuildContext context) {
    final Mind editedMind = widget.mind.copyWith(
      emoji: _emoji,
      note: _text,
    );
    sendEventTo<MindBloc>(
      MindEdit(mind: editedMind),
    );
    Navigator.of(context).pop();
  }

  void _showMindPickerScreen({required Function(String) onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }
}
