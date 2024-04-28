import 'package:keklist/presentation/core/widgets/mind_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

final class MindPickerScreen extends StatefulWidget {
  final Iterable<String> suggestions;
  final Function(String) onSelect;

  const MindPickerScreen({
    super.key,
    required this.onSelect,
    this.suggestions = const [],
  });

  @override
  MindPickerScreenState createState() => MindPickerScreenState();
}

final class MindPickerScreenState extends State<MindPickerScreen> {
  final List<Emoji> _emojies = Emoji.all();
  String _searchText = '';
  Iterable<Emoji> _filteredMinds = [];
  List<String> get _displayedEmojiCharacters {
    final List<String> suggestions = widget.suggestions.toList();
    return suggestions + _displayedEmojies.map((emoji) => emoji.char).toList();
  }
  Iterable<Emoji> get _displayedEmojies => _searchText.isEmpty ? _mainEmojies : _filteredMinds;
  Iterable<Emoji> get _mainEmojies => _emojies;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _searchText = _textEditingController.text;
        _filteredMinds = _mainEmojies.where((mind) => mind.keywords.join().contains(_searchText)).toList();
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
    return Column(
      children: [
        TextField(
          autofocus: true,
          controller: _textEditingController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            border: UnderlineInputBorder(),
            hintText: 'Search your emoji...',
          ),
        ),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final widgetsInRowCount = (constraints.maxWidth / 80).ceil();
              return GridView.custom(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widgetsInRowCount),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final emoji = _displayedEmojiCharacters[index];
                    return MindWidget(
                      item: emoji,
                      onTap: () => _pickEmoji(emoji),
                      isHighlighted: true,
                    );
                  },
                  childCount: _displayedEmojies.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _pickEmoji(String emoji) {
    Navigator.of(context).pop();
    widget.onSelect(emoji);
  }
}
