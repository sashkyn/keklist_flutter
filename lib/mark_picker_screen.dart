import 'package:awesome_emojis/emoji.dart';
import 'package:emarko/storages/pattern_storage.dart';
import 'package:emarko/typealiases.dart';
import 'package:flutter/material.dart';

import 'mark_widget.dart';

class MarkPickerScreen extends StatefulWidget {
  final PatternsStorage storage;
  final ArgumentCallback<CreationMark> onSelect;

  const MarkPickerScreen({
    Key? key,
    required this.onSelect,
    required this.storage,
  }) : super(key: key);

  @override
  _MarkPickerScreenState createState() => _MarkPickerScreenState();
}

class _MarkPickerScreenState extends State<MarkPickerScreen> {
  late final List<Emoji> _patternMarks = widget.storage.getPatterns().map((item) => Emoji.byChar(item.emoji)).toList();
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
                  onTap: () {
                    _savePattern(mark);
                    _pickMark(mark);
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

  void _savePattern(String mark) async {
    final pattern = Pattern(emoji: mark, note: '');
    widget.storage.addPattern(pattern);
  }

  void _pickMark(String emoji) {
    final mark = CreationMark(emoji, '');
    widget.onSelect(mark);
    Navigator.pop(context);
  }
}

class CreationMark {
  final String mark;
  final String note;

  CreationMark(this.mark, this.note);
}
