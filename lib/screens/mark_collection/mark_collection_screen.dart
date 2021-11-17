// ignore_for_file: unused_import

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:emodzen/storages/entities/mark.dart';
import 'package:emodzen/storages/shared_preferences_storage.dart';
import 'package:emodzen/storages/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  static const int _millisecondsInDay = 1000 * 60 * 60 * 24;

  final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  // late final Storage _storage = FirebaseStorage(_obtainStand());
  final SharedPreferencesStorage _storage = SharedPreferencesStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Mark> _values = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _storage.connect();

      _auth.authStateChanges().listen((user) async {
        await _obtainMarks();
      });
      _jumpToNow();
    });
  }

  Future<void> _obtainMarks() async {
    final marks = await _storage.getMarks();
    setState(() => _values = marks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const SettingsScreen()),
        //       );
        //     },
        //     child: const Padding(
        //       padding: EdgeInsets.all(16.0),
        //       child: Icon(
        //         Icons.settings,
        //         color: Colors.black,
        //       ),
        //     ),
        //   ),
        // ],
        title: GestureDetector(
          onTap: () => _scrollToNow(),
          child: const Text(
            'Emodzen',
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
                    showOkAlertDialog(
                      title: item.emoji,
                      message: item.note,
                      context: context,
                    );
                  },
                  onLongPress: () async {
                    final result = await showModalActionSheet(
                      context: context,
                      actions: [
                        const SheetAction(
                          icon: Icons.delete,
                          label: 'Copy to now',
                          key: 'copy_to_now_key',
                        ),
                        const SheetAction(
                          icon: Icons.delete,
                          label: 'Delete',
                          key: 'remove_key',
                          isDestructiveAction: true,
                        ),
                      ],
                    );
                    if (result == 'remove_key') {
                      await _storage.removeMarkFromDay(item.uuid);
                      setState(() => _values.remove(item));
                    } else if (result == 'copy_to_now_key') {
                      final note = await showTextInputDialog(
                        context: context,
                        message: item.emoji,
                        textFields: [
                          DialogTextField(
                            initialText: item.note,
                            maxLines: 3,
                          )
                        ],
                      );
                      if (note == null) {
                        return;
                      }
                      _addMarkToStorage(
                        dayIndex: _getNowDayIndex(),
                        note: note.first,
                        emoji: item.emoji,
                        sortIndex: _findMarksByDayIndex(index).length,
                      );
                    }
                  },
                ),
              )
              .toList();

          widgets.add(MarkWidget(
            item: '📝',
            onTap: () async => await _showMarkPickerScreen(context, index),
          ));

          return Column(
            children: [
              Text(
                _formatter.format(_getDateFromInt(index)),
                style: TextStyle(fontWeight: index == _getNowDayIndex() ? FontWeight.bold : FontWeight.normal),
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

  _showMarkPickerScreen(BuildContext context, int index) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
          body: MarkPickerScreen(
            onSelect: (creationMark) async {
              await _addMarkToStorage(
                dayIndex: index,
                note: creationMark.note,
                emoji: creationMark.mark,
                sortIndex: _findMarksByDayIndex(index).length,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addMarkToStorage({
    required int dayIndex,
    required String note,
    required String emoji,
    required int sortIndex,
  }) async {
    final mark = Mark(
      uuid: const Uuid().v4(),
      dayIndex: dayIndex,
      note: note,
      emoji: emoji,
      creationDate: DateTime.now().millisecondsSinceEpoch,
      sortIndex: sortIndex,
    );
    await _storage.addMark(mark);
    setState(() => _values.add(mark));
  }

  DateTime _getDateFromInt(int index) => DateTime.fromMillisecondsSinceEpoch(_millisecondsInDay * index);

  int _getDayIndex(DateTime date) =>
      (date.millisecondsSinceEpoch + date.timeZoneOffset.inMilliseconds) ~/ _millisecondsInDay;

  List<Mark> _findMarksByDayIndex(int index) =>
      _values.where((item) => index == item.dayIndex).sortedBy((it) => it.sortIndex).toList();

  // String _obtainStand() {
  //   if (kReleaseMode) {
  //     return 'release';
  //   } else {
  //     return 'debug';
  //   }
  // }

  void _jumpToNow() {
    _itemScrollController.jumpTo(
      index: _getNowDayIndex(),
      alignment: 0.02,
    );
  }

  void _scrollToNow() {
    _itemScrollController.scrollTo(
      index: _getNowDayIndex(),
      alignment: 0.02,
      duration: const Duration(milliseconds: 200),
    );
  }

  int _getNowDayIndex() => _getDayIndex(DateTime.now());
}

// MARK: Sorted by.

extension MyIterable<E> on Iterable<E> {
  Iterable<E> sortedBy(Comparable Function(E e) key) => toList()..sort((a, b) => key(a).compareTo(key(b)));
}
