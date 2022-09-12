import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/typealiases.dart';
import 'package:zenmode/widgets/mark_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MarkCreatorScreen extends StatefulWidget {
  final ArgumentCallback<CreateMarkData> onCreate;

  const MarkCreatorScreen({
    Key? key,
    required this.onCreate,
  }) : super(key: key);

  @override
  _MarkCreatorScreenState createState() => _MarkCreatorScreenState();
}

class _MarkCreatorScreenState extends State<MarkCreatorScreen> {
  String _emoji = Emoji.all().first.char;
  String _text = '';

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _text = _textEditingController.text;
        // _filteredMarks = _mainMarks.where((mark) => mark.keywords.join().contains(_searchText)).toList();
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
          MarkWidget(
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
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            controller: _textEditingController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: 'Enter text for mark...',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pop();
          final CreateMarkData data = CreateMarkData(
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

class CreateMarkData {
  final String text;
  final String emoji;

  const CreateMarkData({
    required this.text,
    required this.emoji,
  });
}
