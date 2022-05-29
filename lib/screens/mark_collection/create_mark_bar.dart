import 'package:emodzen/screens/mark_creator/mark_creator_screen.dart';
import 'package:emodzen/typealiases.dart';
import 'package:emodzen/widgets/mark_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

class CreateMarkBar extends StatefulWidget {
  final TextEditingController textEditingController;
  final List<String> suggestionMarks;
  final ArgumentCallback<CreateMarkData> onKek;
  final FocusNode focusNode;

  const CreateMarkBar({
    Key? key,
    required this.textEditingController,
    required this.suggestionMarks,
    required this.onKek,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<CreateMarkBar> createState() => _CreateMarkBarState();
}

class _CreateMarkBarState extends State<CreateMarkBar> {
  String _selectedEmoji = Emoji.all().first.char;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.grey),
            Row(
              children: List.generate(widget.suggestionMarks.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkWidget.sized(
                    item: widget.suggestionMarks[index],
                    markSize: MarkSize.small,
                    onTap: () {
                      setState(() {
                        _selectedEmoji = widget.suggestionMarks[index];
                      });
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const SizedBox(width: 8.0),
                MarkWidget.sized(item: _selectedEmoji, markSize: MarkSize.medium),
                const SizedBox(width: 8.0),
                Flexible(
                  flex: 1,
                  child: TextField(
                    focusNode: widget.focusNode,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    controller: widget.textEditingController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      hintText: 'Create new mark with text',
                      suffixIcon: TextButton(
                        style: ButtonStyle(
                          splashFactory: NoSplash.splashFactory,
                          foregroundColor: MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: () {
                          final data = CreateMarkData(
                            text: widget.textEditingController.text,
                            emoji: _selectedEmoji,
                          );
                          widget.onKek(data);
                        },
                        child: const Text(
                          'KEK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2.0),
              ],
            ),
            const SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }
}
