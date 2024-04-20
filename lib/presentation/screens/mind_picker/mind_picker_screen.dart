import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/widgets/mind_widget.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

class MindPickerScreen extends StatefulWidget {
  final Function(String) onSelect;

  const MindPickerScreen({
    super.key,
    required this.onSelect,
  });

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
                    final mind = _displayedMinds[index].char;
                    return MindWidget(
                      item: mind,
                      onTap: () => _pickMark(mind),
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
    );
  }

  void _pickMark(String emoji) {
    Navigator.of(context).pop();
    widget.onSelect(emoji);
  }
}
