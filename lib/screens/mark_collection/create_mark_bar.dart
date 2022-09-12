import 'package:zenmode/screens/mark_creator/mark_creator_screen.dart';
import 'package:zenmode/typealiases.dart';
import 'package:zenmode/widgets/mark_widget.dart';
import 'package:flutter/material.dart';

class CreateMarkBar extends StatelessWidget {
  final TextEditingController textEditingController;
  final List<String> suggestionMarks;
  final FocusNode focusNode;
  final String selectedEmoji;
  final VoidCallback onSearchEmoji;
  final ArgumentCallback<String> onSelectSuggestionEmoji;
  final ArgumentCallback<CreateMarkData> onKek;

  const CreateMarkBar({
    Key? key,
    required this.textEditingController,
    required this.suggestionMarks,
    required this.onKek,
    required this.focusNode,
    required this.selectedEmoji,
    required this.onSelectSuggestionEmoji,
    required this.onSearchEmoji,
  }) : super(key: key);

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
              children: List.generate(suggestionMarks.length, (index) {
                return Flexible(
                  flex: 1,
                  child: MarkWidget.sized(
                    item: suggestionMarks[index],
                    markSize: MarkSize.small,
                    onTap: () => onSelectSuggestionEmoji(suggestionMarks[index]),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const SizedBox(width: 8.0),
                MarkWidget.sized(
                  item: selectedEmoji,
                  markSize: MarkSize.medium,
                  onTap: onSearchEmoji,
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  flex: 1,
                  child: TextField(
                    focusNode: focusNode,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    controller: textEditingController,
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
                            text: textEditingController.text,
                            emoji: selectedEmoji,
                          );
                          onKek(data);
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
