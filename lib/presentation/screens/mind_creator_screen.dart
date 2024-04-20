import 'package:flutter/material.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/mind_picker/mind_picker_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// TODO: suggestions
// TODO: editing minds

final class MindCreatorScreen extends StatefulWidget {
  final Function(String text, String emoji) onDone;
  final String? initialText;
  final String? initialEmoji;

  const MindCreatorScreen({
    super.key,
    required this.onDone,
    this.initialText,
    this.initialEmoji,
  });

  @override
  State<MindCreatorScreen> createState() => _MindCreatorScreenState();
}

final class _MindCreatorScreenState extends KekWidgetState<MindCreatorScreen> {
  final TextEditingController textEditingController = TextEditingController();
  String _selectedEmoji = '🙂';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialText != null) {
        textEditingController.text = widget.initialText!;
      }
      if (widget.initialEmoji != null) {
        setState(() {
          _selectedEmoji = widget.initialEmoji!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 0,
        leading: const SizedBox.shrink(),
        actions: [
          TextButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              foregroundColor: MaterialStateProperty.all(Colors.blueAccent),
            ),
            onPressed: () {
              widget.onDone(textEditingController.text, _selectedEmoji);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _showEmojiPickerScreen(onSelect: (emoji) {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                });
              },
              child: Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 64.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              controller: textEditingController,
              style: const TextStyle(fontSize: 20.0),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12.0),
                border: InputBorder.none,
                hintText: 'Write a mind...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPickerScreen({required Function(String) onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }
}
