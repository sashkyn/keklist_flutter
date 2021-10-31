// ignore_for_file: prefer_const_constructors

import 'package:awesome_emojis/emoji.dart';
import 'package:emarko/typealiases.dart';
import 'package:flutter/material.dart';

class MarkPickerScreen extends StatefulWidget {
  final ArgumentCallback<CreationMark> onSelect;

  const MarkPickerScreen({Key? key, required this.onSelect}) : super(key: key);

  @override
  _MarkPickerScreenState createState() => _MarkPickerScreenState();
}

class _MarkPickerScreenState extends State<MarkPickerScreen> {
  final List<Emoji> _usedMarks = Emoji.byKeyword('love').toList();

  final List<Emoji> _marks = Emoji.all();

  String _searchText = '';

  List<Emoji> _filteredMarks = [];

  List<Emoji> get _displayedMarks => _searchText.isEmpty ? _marks : _filteredMarks;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        _searchText = _textEditingController.text;
        _filteredMarks = _marks.where((mark) => mark.keywords.join().contains(_searchText)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search mark',
          ),
        ),
        // Flexible(
        //   child: GridView.count(
        //     shrinkWrap: true,
        //     crossAxisCount: 5,
        //     children: _usedMarks.map((mark) => _makeMarkWidget(mark.char)).toList(),
        //   ),
        // ),
        Flexible(
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _displayedMarks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemBuilder: (BuildContext context, int index) {
              return _makeMarkWidget(_displayedMarks[index].char);
            },
          ),
        ),
      ],
    );
  }

  Widget _makeMarkWidget(String item) {
    return GestureDetector(
      onTap: () {
        var mark = CreationMark(item, '');
        widget.onSelect(mark);
        Navigator.pop(context);
      },
      child: Center(
        child: Text(
          item,
          style: const TextStyle(fontSize: 55),
        ),
      ),
    );
  }
}

class CreationMark {
  final String mark;
  final String note;

  CreationMark(this.mark, this.note);
}
