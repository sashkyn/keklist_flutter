import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/widgets/mind_widget.dart';
import 'package:flutter/material.dart';
import 'package:keklist/presentation/core/widgets/sensitive_widget.dart';

// TODO: превратить suggestions в миничипсы и убрать эмодзик слева как нибудь

final class MindCreatorBottomBar extends StatefulWidget {
  final Mind? editableMind;
  final TextEditingController textEditingController;
  final List<String> suggestionMinds;
  final FocusNode focusNode;
  final String? selectedEmoji;
  final VoidCallback onTapEmoji;
  final String doneTitle;
  final String placeholder;
  final Function(String) onTapSuggestionEmoji;
  final VoidCallback onTapCancelEdit;
  final Function(CreateMindData) onDone;

  const MindCreatorBottomBar({
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
  State<MindCreatorBottomBar> createState() => _MindCreatorBottomBarState();
}

class _MindCreatorBottomBarState extends State<MindCreatorBottomBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            const _HorizontalSeparator(),
            if (widget.editableMind != null) ...[
              _EditableMindInfoWidget(
                editableMind: widget.editableMind!,
                onTapCancelEdit: widget.onTapCancelEdit,
                onTapEmoji: widget.onTapEmoji,
              ),
              const _HorizontalSeparator(),
            ],
            if (widget.suggestionMinds.isNotEmpty &&
                MediaQuery.of(context).orientation != Orientation.landscape &&
                DeviceUtils.isPhone(context)) ...[
              SensitiveWidget(
                mode: SensitiveMode.blurredAndNonTappable,
                child: _SuggestionsWidget(
                  suggestionMinds: widget.suggestionMinds,
                  onSelectSuggestionEmoji: widget.onTapSuggestionEmoji,
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            _TextFieldWidget(
              selectedEmoji: widget.selectedEmoji,
              onSearchEmoji: widget.onTapEmoji,
              placeholder: widget.placeholder,
              focusNode: widget.focusNode,
              textEditingController: widget.textEditingController,
              onDone: () {
                widget.onDone(
                  CreateMindData(
                    emoji: widget.selectedEmoji ?? '',
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

class _EditableMindInfoWidget extends StatelessWidget {
  final Mind editableMind;
  final Function() onTapEmoji;
  final Function() onTapCancelEdit;

  const _EditableMindInfoWidget({
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
          color: Theme.of(context).disabledColor,
          height: 38.0,
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

class _HorizontalSeparator extends StatelessWidget {
  const _HorizontalSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).disabledColor,
      height: 0.3,
    );
  }
}

class _TextFieldWidget extends StatelessWidget {
  const _TextFieldWidget({
    required this.selectedEmoji,
    required this.placeholder,
    required this.onSearchEmoji,
    required this.focusNode,
    required this.textEditingController,
    required this.onDone,
  });

  final String? selectedEmoji;
  final VoidCallback onSearchEmoji;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final String placeholder;
  final Function() onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4.0),
        if (selectedEmoji != null) ...[
          MindWidget.sized(
            item: selectedEmoji!,
            size: MindSize.medium,
            onTap: onSearchEmoji,
            badge: null,
          ),
          const SizedBox(width: 4.0),
        ],
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
            child: TextField(
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              maxLines: () {
                if (MediaQuery.of(context).orientation != Orientation.landscape && DeviceUtils.isPhone(context)) {
                  return null;
                } else {
                  return 1;
                }
              }(),
              textCapitalization: TextCapitalization.sentences,
              controller: textEditingController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                hintText: placeholder,
                suffixIcon: SensitiveWidget(
                  mode: SensitiveMode.blurredAndNonTappable,
                  child: TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: WidgetStateProperty.all(Colors.blueAccent),
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
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }
}

class _SuggestionsWidget extends StatelessWidget {
  const _SuggestionsWidget({
    required this.suggestionMinds,
    required this.onSelectSuggestionEmoji,
  });

  final List<String> suggestionMinds;
  final Function(String) onSelectSuggestionEmoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.0,
      child: Row(
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
      ),
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
