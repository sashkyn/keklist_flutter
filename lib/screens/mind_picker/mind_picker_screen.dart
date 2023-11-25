import 'package:keklist/constants.dart';
import 'package:keklist/widgets/mind_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

class MindPickerScreen extends StatefulWidget {
  final Function(String) onSelect;

  const MindPickerScreen({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  MindPickerScreenState createState() => MindPickerScreenState();
}

class MindPickerScreenState extends State<MindPickerScreen> {
  final List<Emoji> _emojies = Emoji.all();
  String _searchText = '';
  List<Emoji> _filteredMinds = [];
  List<Emoji> get _displayedMinds => _searchText.isEmpty ? _mainMinds : _filteredMinds;
  List<Emoji> get _mainMinds => _emojies;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _searchText = _textEditingController.text;
        _filteredMinds = _mainMinds.where((mind) => mind.keywords.join().contains(_searchText)).toList();
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
                      final mark = _displayedMinds[index].char;
                      return MindWidget(
                        item: mark,
                        onTap: () => _pickMark(mark),
                        isHighlighted: true,
                      );
                    },
                    childCount: _displayedMinds.length,
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
