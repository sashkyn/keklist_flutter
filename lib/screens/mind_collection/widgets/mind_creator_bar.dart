import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/widgets/mind_widget.dart';
import 'package:flutter/material.dart';

// TODO: превратить suggestions в миничипсы и убрать эмодзик слева как нибудь

class MindCreatorBar extends StatefulWidget {
  final Mind? editableMind;
  final TextEditingController textEditingController;
  final List<String> suggestionMinds;
  final FocusNode focusNode;
  final String selectedEmoji;
  final VoidCallback onTapEmoji;
  final String doneTitle;
  final Function(String) onTapSuggestionEmoji;
  final Function() onTapCancelEdit;
  final Function(CreateMindData) onDone;

  const MindCreatorBar({
    Key? key,
    required this.textEditingController,
    required this.suggestionMinds,
    required this.focusNode,
    required this.selectedEmoji,
    required this.doneTitle,
    required this.onDone,
    required this.onTapEmoji,
    required this.onTapSuggestionEmoji,
    this.editableMind,
    required this.onTapCancelEdit,
  }) : super(key: key);

  @override
  State<MindCreatorBar> createState() => _MindCreatorBarState();
}

class _MindCreatorBarState extends State<MindCreatorBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.editableMind != null) ...[
              const MindCreatorSeparator(),
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.edit,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                          color: Colors.grey,
                          height: 40,
                          width: 1,
                        ),
                        const SizedBox(width: 12.0),
                        MindWidget.sized(
                          item: widget.editableMind!.emoji,
                          size: MindSize.small,
                          onTap: widget.onTapEmoji,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          widget.editableMind!.note,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onTapCancelEdit,
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
            const MindCreatorSeparator(),
            MindCreatorSuggestionsWidget(
              suggestionMinds: widget.suggestionMinds,
              onSelectSuggestionEmoji: widget.onTapSuggestionEmoji,
            ),
            const SizedBox(height: 8.0),
            MindCreatorTextFieldWidget(
              selectedEmoji: widget.selectedEmoji,
              onSearchEmoji: widget.onTapEmoji,
              focusNode: widget.focusNode,
              textEditingController: widget.textEditingController,
              onDone: () {
                widget.onDone.call(
                  CreateMindData(
                    emoji: widget.selectedEmoji,
                    text: widget.textEditingController.text,
                  ),
                );
              },
            ),
            const SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }
}

class MindCreatorSeparator extends StatelessWidget {
  const MindCreatorSeparator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      height: 0.3,
    );
  }
}

class MindCreatorTextFieldWidget extends StatelessWidget {
  const MindCreatorTextFieldWidget({
    super.key,
    required this.selectedEmoji,
    required this.onSearchEmoji,
    required this.focusNode,
    required this.textEditingController,
    required this.onDone,
  });

  final String selectedEmoji;
  final VoidCallback onSearchEmoji;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final Function() onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8.0),
        MindWidget.sized(
          item: selectedEmoji,
          size: MindSize.medium,
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
              hintText: 'Create a mind...',
              suffixIcon: TextButton(
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                onPressed: onDone,
                child: const Text(
                  'DONE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2.0),
      ],
    );
  }
}

class MindCreatorSuggestionsWidget extends StatelessWidget {
  const MindCreatorSuggestionsWidget({
    super.key,
    required this.suggestionMinds,
    required this.onSelectSuggestionEmoji,
  });

  final List<String> suggestionMinds;
  final Function(String) onSelectSuggestionEmoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(suggestionMinds.length, (index) {
        return Flexible(
          flex: 1,
          child: MindWidget.sized(
            item: suggestionMinds[index],
            size: MindSize.small,
            onTap: () => onSelectSuggestionEmoji(suggestionMinds[index]),
          ),
        );
      }),
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
