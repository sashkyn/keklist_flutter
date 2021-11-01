import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'mark_picker_screen.dart';
import 'mark_widget.dart';
import 'storages/pattern_storage.dart';

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

  final Storage _storage = Storage();

  List<Mark> _findMarksByDayIndex(int index) => _values.where((item) => index == item.dayIndex).toList();

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
      appBar: AppBar(
        title: const Text(
          'Keklist',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ScrollablePositionedList.builder(
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: 99999999999,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (BuildContext context, int index) {
          final List<Widget> widgets = _findMarksByDayIndex(index)
              .map(
                (item) => MarkWidget(
                  item: item.emoji,
                  onTap: () {
                    showOkAlertDialog(title: item.emoji, message: item.note, context: context);
                  },
                  onLongPress: () async {
                    final result = await showModalActionSheet<String>(
                      context: context,
                      actions: [
                        const SheetAction(
                          icon: Icons.delete,
                          label: 'Delete',
                          key: 'remove_key',
                          isDestructiveAction: true,
                        ),
                      ],
                    );
                    setState(() {
                      if (result == 'remove_key') {
                        _storage.removeMarkFromDay(item.dayIndex, item.emoji);
                        _values.remove(item);
                      }
                    });
                  },
                ),
              )
              .toList();

          widgets.add(MarkWidget(
            item: '📝',
            onTap: () => _showMarkPickerScreen(context, index),
          ));

          return Column(
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
      builder: (context) => MarkPickerScreen(
          storage: _storage,
          onSelect: (creationMark) {
            setState(
              () {
                final mark = Mark(dayIndex: index, note: creationMark.note, emoji: creationMark.mark);
                _storage.addMark(mark);
                _values.add(mark);
              },
            );
          }),
    );
  }

  DateTime _getDateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(1000 * 1000 * 60 * 60 * 24 * index);

  int _getDayIndex(DateTime date) => (date.microsecondsSinceEpoch / (1000 * 1000 * 60 * 60 * 24)).round();

  void _jumpToNow() {
    _itemScrollController.jumpTo(index: _getDayIndex(DateTime.now()));
  }
}
