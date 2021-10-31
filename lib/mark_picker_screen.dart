import 'package:emarko/typealiases.dart';
import 'package:flutter/material.dart';

class MarkPickerScreen extends StatefulWidget {
  final ArgumentCallback<CreationMark> onSelect;

  const MarkPickerScreen({Key? key, required this.onSelect}) : super(key: key);

  @override
  _MarkPickerScreenState createState() => _MarkPickerScreenState();
}

class _MarkPickerScreenState extends State<MarkPickerScreen> {
  final List<String> marks = ["🔫", "🏃", "💩", "🤖", "💪", "☕", "✨", "👩", "💦", "🇻🇬", "✅"];

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = marks.map((item) {
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
    }).toList();

    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 5,
      children: widgets,
    );
  }
}

class CreationMark {
  final String mark;
  final String note;

  CreationMark(this.mark, this.note);
}
