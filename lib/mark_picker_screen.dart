import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:awesome_emojis/emoji.dart';
import 'package:flutter/material.dart';

import 'mark_widget.dart';
import 'typealiases.dart';

class MarkPickerScreen extends StatefulWidget {
  final ArgumentCallback<CreationMark> onSelect;

  const MarkPickerScreen({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  _MarkPickerScreenState createState() => _MarkPickerScreenState();
}

class _MarkPickerScreenState extends State<MarkPickerScreen> {
  late final List<Emoji> _patternMarks = [];
  //widget.storage.getPatterns().map((item) => Emoji.byChar(item.emoji)).toList();
  final List<Emoji> _marks = Emoji.all();
  String _searchText = '';
  List<Emoji> _filteredMarks = [];
  List<Emoji> get _displayedMarks => _searchText.isEmpty ? _mainMarks : _filteredMarks;
  List<Emoji> get _mainMarks => _patternMarks + _marks.where((mark) => !_patternMarks.contains(mark)).toList();

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _searchText = _textEditingController.text;
        _filteredMarks = _mainMarks.where((mark) => mark.keywords.join().contains(_searchText)).toList();
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
          controller: _textEditingController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            border: UnderlineInputBorder(),
            hintText: 'Search emoji mark',
          ),
        ),
        Flexible(
          child: GridView.custom(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                final mark = _displayedMarks[index].char;
                return MarkWidget(
                  item: mark,
                  onTap: () async {
                    final note = await showTextInputDialog(
                      context: context,
                      message: 'Description',
                      textFields: [const DialogTextField(initialText: '', maxLines: 3)],
                    );
                    // final pattern = Pattern(emoji: mark, note: note?.first ?? '');
                    // _savePattern(pattern);
                    _pickMark(mark, note?.first ?? '');
                  },
                );
              },
              childCount: _displayedMarks.length,
            ),
          ),
        ),
      ],
    );
  }

  // void _savePattern(Pattern pattern) async {
  //   widget.storage.addPattern(pattern);
  // }

  void _pickMark(String emoji, String note) {
    final mark = CreationMark(emoji, note);
    widget.onSelect(mark);
    Navigator.pop(context);
  }
}

class CreationMark {
  final String mark;
  final String note;

  CreationMark(this.mark, this.note);
}
