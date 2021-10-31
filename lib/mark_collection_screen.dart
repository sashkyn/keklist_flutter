import 'package:emarko/storages/pattern_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'mark_picker_screen.dart';
import 'mark_widget.dart';

class MarkCollectionScreen extends StatefulWidget {
  const MarkCollectionScreen({Key? key}) : super(key: key);

  @override
  State<MarkCollectionScreen> createState() => _MarkCollectionScreenState();
}

class _MarkCollectionScreenState extends State<MarkCollectionScreen> {
  List<Mark> _values = [];
  final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  final PatternsStorage _storage = PatternsStorage();

  Mark _findMarkByEmoji(String emoji) => _values.firstWhere((item) => emoji == item.emoji);

  List<Mark> _findMarkByDayIndex(int index) => _values.where((item) => index == item.dayIndex).toList();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _storage.connect();
      setState(() {
        _values = _storage.getMarks();
        _jumpToNow();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KEKList')),
      body: ScrollablePositionedList.builder(
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: 99999999999,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (BuildContext context, int index) {
          final List<Widget> widgets =
              _findMarkByDayIndex(index).map((item) => _makeMarkWidget(item: item.emoji)).toList();

          widgets.add(_makeMarkWidget(
            item: '📝',
            onTap: () => _showMarkPickerScreen(context, index),
          ));

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                _formatter.format(_getDateFromInt(index)),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              GridView.count(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 5,
                children: widgets,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMarkPickerScreen(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MarkPickerScreen(
            storage: _storage,
            onSelect: (creationMark) {
              setState(
                () {
                  final mark = Mark(dayIndex: index, note: creationMark.note, emoji: creationMark.mark);
                  _storage.addMark(mark);
                  _values.add(mark);
                },
              );
            });
      },
    );
  }

  Widget _makeMarkWidget({required String item, VoidCallback? onTap}) {
    return MarkWidget(
      item: item,
      onTap: onTap,
    );
  }

  DateTime _getDateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(1000 * 1000 * 60 * 60 * 24 * index);

  int _getDayIndex(DateTime date) => (date.microsecondsSinceEpoch / (1000 * 1000 * 60 * 60 * 24)).round();

  void _jumpToNow() {
    _itemScrollController.jumpTo(index: _getDayIndex(DateTime.now()));
  }
}
