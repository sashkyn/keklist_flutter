import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

import '../../widgets/mark_widget.dart';
import '../../typealiases.dart';

class MarkPickerScreen extends StatefulWidget {
  final ArgumentCallback<String> onSelect;

  const MarkPickerScreen({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  _MarkPickerScreenState createState() => _MarkPickerScreenState();
}

class _MarkPickerScreenState extends State<MarkPickerScreen> {
  final List<Emoji> _marks = Emoji.all();
  String _searchText = '';
  List<Emoji> _filteredMarks = [];
  List<Emoji> get _displayedMarks => _searchText.isEmpty ? _mainMarks : _filteredMarks;
  List<Emoji> get _mainMarks => _marks;

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
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                final mark = _displayedMarks[index].char;
                return MarkWidget(
                  item: mark,
                  onTap: () => _pickMark(mark),
                  isHighlighted: true,
                );
              },
              childCount: _displayedMarks.length,
            ),
          ),
        ),
      ],
    );
  }

  void _pickMark(String emoji) {
    Navigator.of(context).pop();
    widget.onSelect(emoji);
  }
}
