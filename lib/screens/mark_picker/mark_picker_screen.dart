import 'package:rememoji/constants.dart';
import 'package:rememoji/typealiases.dart';
import 'package:rememoji/widgets/mind_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

class MarkPickerScreen extends StatefulWidget {
  final ArgumentCallback<String> onSelect;

  const MarkPickerScreen({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  MarkPickerScreenState createState() => MarkPickerScreenState();
}

class MarkPickerScreenState extends State<MarkPickerScreen> {
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
    return Scaffold(
      body: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _textEditingController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: UnderlineInputBorder(),
              hintText: 'Search emoji mark',
            ),
          ),
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final widgetsInRowCount = (constraints.maxWidth / LayoutConstants.mindSide).ceil();
                return GridView.custom(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widgetsInRowCount),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mark = _displayedMarks[index].char;
                      return MindWidget(
                        item: mark,
                        onTap: () => _pickMark(mark),
                        isHighlighted: true,
                      );
                    },
                    childCount: _displayedMarks.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickMark(String emoji) {
    Navigator.of(context).pop();
    widget.onSelect(emoji);
  }
}
