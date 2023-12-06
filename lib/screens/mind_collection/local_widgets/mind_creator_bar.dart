import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/mind_widget.dart';
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
  final String placeholder;
  final Function(String) onTapSuggestionEmoji;
  final VoidCallback onTapCancelEdit;
  final Function(CreateMindData) onDone;

  const MindCreatorBar({
    super.key,
    required this.textEditingController,
    required this.suggestionMinds,
    required this.focusNode,
    required this.selectedEmoji,
    required this.doneTitle,
    required this.onDone,
    required this.onTapEmoji,
    required this.onTapSuggestionEmoji,
    required this.placeholder,
    this.editableMind,
    required this.onTapCancelEdit,
  });

  @override
  State<MindCreatorBar> createState() => _MindCreatorBarState();
}

class _MindCreatorBarState extends State<MindCreatorBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            const MindCreatorSeparator(),
            if (widget.editableMind != null) ...[
              MindCreatorEditableMindInfoWidget(
                editableMind: widget.editableMind!,
                onTapCancelEdit: widget.onTapCancelEdit,
                onTapEmoji: widget.onTapEmoji,
              ),
              const MindCreatorSeparator(),
            ],
            if (widget.suggestionMinds.isNotEmpty) ...[
              MindCreatorSuggestionsWidget(
                suggestionMinds: widget.suggestionMinds,
                onSelectSuggestionEmoji: widget.onTapSuggestionEmoji,
              ),
              const SizedBox(height: 8.0),
            ],
            MindCreatorTextFieldWidget(
              selectedEmoji: widget.selectedEmoji,
              onSearchEmoji: widget.onTapEmoji,
              placeholder: widget.placeholder,
              focusNode: widget.focusNode,
              textEditingController: widget.textEditingController,
              onDone: () {
                widget.onDone(
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

class MindCreatorEditableMindInfoWidget extends StatelessWidget {
  final Mind editableMind;
  final Function() onTapEmoji;
  final Function() onTapCancelEdit;

  const MindCreatorEditableMindInfoWidget({
    super.key,
    required this.editableMind,
    required this.onTapEmoji,
    required this.onTapCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(Icons.edit),
        ),
        Container(
          color: Theme.of(context).dividerColor,
          height: 55.0,
          width: 0.3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MindWidget.sized(
                  item: editableMind.emoji,
                  size: MindSize.small,
                  onTap: onTapEmoji,
                  badge: null,
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    editableMind.note.replaceAll('\n', ' '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onTapCancelEdit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MindCreatorSeparator extends StatelessWidget {
  const MindCreatorSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).dividerColor,
      height: 0.3,
    );
  }
}

class MindCreatorTextFieldWidget extends StatelessWidget {
  const MindCreatorTextFieldWidget({
    super.key,
    required this.selectedEmoji,
    required this.placeholder,
    required this.onSearchEmoji,
    required this.focusNode,
    required this.textEditingController,
    required this.onDone,
  });

  final String selectedEmoji;
  final VoidCallback onSearchEmoji;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final String placeholder;
  final Function() onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6.0),
        MindWidget.sized(
          item: selectedEmoji,
          size: MindSize.medium,
          onTap: onSearchEmoji,
          badge: null,
        ),
        const SizedBox(width: 5.0),
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
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
                hintText: placeholder,
                suffixIcon: TextButton(
                  style: ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                    foregroundColor: MaterialStateProperty.all(Colors.blueAccent),
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
        ),
        const SizedBox(width: 6.0),
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
            badge: null,
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
