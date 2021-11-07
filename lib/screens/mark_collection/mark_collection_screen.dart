// ignore_for_file: avoid_print

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keklist/screens/settings/settings_screen.dart';
import 'package:keklist/storages/entities/mark.dart';
import 'package:keklist/storages/firebase_storage.dart';
import 'package:keklist/storages/shared_preferences_storage.dart';
import 'package:keklist/storages/storage.dart';
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
  static const int _millisecondsInDay = 1000 * 1000 * 60 * 60 * 24;

  final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  late final Storage _storage = FirebaseStorage(_obtainStand());
  // final Storage _storage = SharedPreferencesStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Mark> _values = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _storage.connect();
      await _obtainMarks();

      _auth.authStateChanges().listen((user) async => await _obtainMarks());
    });
  }

  Future<void> _obtainMarks() async {
    print('obtaining...');
    final marks = await _storage.getMarks();
    setState(() {
      _values = marks;
      _jumpToNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.settings, color: Colors.black),
            ),
          ),
        ],
        title: GestureDetector(
          onTap: () => _scrollToNow(),
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
                          label: 'Delete',
                          key: 'remove_key',
                          isDestructiveAction: true,
                        ),
                      ],
                    );
                    if (result == 'remove_key') {
                      await _storage.removeMarkFromDay(item.uuid);
                      setState(() => _values.remove(item));
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
          creationDate: DateTime.now().millisecondsSinceEpoch,
          sortIndex: _findMarksByDayIndex(index).length,
        );
        await _storage.addMark(mark);
        setState(() => _values.add(mark));
      }),
    );
  }

  DateTime _getDateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(_millisecondsInDay * index);

  int _getDayIndex(DateTime date) => (date.microsecondsSinceEpoch / _millisecondsInDay).round();

  List<Mark> _findMarksByDayIndex(int index) =>
      _values.where((item) => index == item.dayIndex).sortedBy((it) => it.sortIndex).toList();

  String _obtainStand() {
    if (kReleaseMode) {
      return 'release';
    } else {
      return 'debug';
    }
  }

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

// MARK: Sorted by.

extension MyIterable<E> on Iterable<E> {
  Iterable<E> sortedBy(Comparable Function(E e) key) => toList()..sort((a, b) => key(a).compareTo(key(b)));
}
