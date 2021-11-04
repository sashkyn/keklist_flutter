import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keklist/screens/auth/auth_screen.dart';
import 'package:keklist/storages/entities/mark.dart';
import 'package:keklist/storages/firebase_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

import '../mark_picker/mark_picker_screen.dart';
import '../../widgets/mark_widget.dart';

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

  final FirebaseStorage _firebaseStorage = FirebaseStorage();

  List<Mark> _findMarksByDayIndex(int index) => _values.where((item) => index == item.dayIndex).toList();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final marks = await _firebaseStorage.getMarks();
      setState(() {
        _values = marks;
        _jumpToNow();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AuthScreen();
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Icon(Icons.login, color: Colors.black),
            ),
          ),
        ],
        title: GestureDetector(
          onTap: () {
            _scrollToNow();
          },
          child: const Text(
            'Keklist',
            style: TextStyle(color: Colors.black),
          ),
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
                    final result = await showModalActionSheet(
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
                    if (result == 'remove_key') {
                      await _firebaseStorage.removeMarkFromDay(item.uuid);
                      setState(() {
                        _values.remove(item);
                      });
                    }
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
      builder: (context) => MarkPickerScreen(onSelect: (creationMark) async {
        final mark = Mark(
          uuid: const Uuid().v4(),
          dayIndex: index,
          note: creationMark.note,
          emoji: creationMark.mark,
        );
        await _firebaseStorage.addMark(mark);
        setState(
          () {
            _values.add(mark);
          },
        );
      }),
    );
  }

  DateTime _getDateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(1000 * 1000 * 60 * 60 * 24 * index);

  int _getDayIndex(DateTime date) => (date.microsecondsSinceEpoch / (1000 * 1000 * 60 * 60 * 24)).round();

  void _jumpToNow() {
    _itemScrollController.jumpTo(
      index: _getDayIndex(DateTime.now()),
      alignment: 0.2,
    );
  }

  void _scrollToNow() {
    _itemScrollController.scrollTo(
      index: _getDayIndex(DateTime.now()),
      alignment: 0.2,
      duration: const Duration(milliseconds: 200),
    );
  }
}
