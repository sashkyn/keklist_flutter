import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:emodzen/blocs/mark_bloc/mark_bloc.dart';
import 'package:emodzen/screens/mark_collection/create_mark_bar.dart';
import 'package:emodzen/screens/mark_collection/search_bar.dart';
import 'package:emodzen/screens/mark_creator/mark_creator_screen.dart';
import 'package:emodzen/screens/settings/settings_screen.dart';
import 'package:emodzen/storages/entities/mark.dart';
import 'package:emodzen/typealiases.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../mark_picker/mark_picker_screen.dart';
import '../../widgets/mark_widget.dart';

class MarkCollectionScreen extends StatefulWidget {
  const MarkCollectionScreen({Key? key}) : super(key: key);

  @override
  State<MarkCollectionScreen> createState() => _MarkCollectionScreenState();
}

class _MarkCollectionScreenState extends State<MarkCollectionScreen> {
  static const int _millisecondsInDay = 1000 * 60 * 60 * 24;
  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  List<Mark> _marks = [];
  SearchingMarkState? _searchingMarkState;

  final TextEditingController _searchTextController = TextEditingController(text: null);

  get _isSearching => _searchingMarkState != null && _searchingMarkState!.enabled;
  get _searchedValues => _isSearching ? _searchingMarkState!.filteredValues : [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();

      _sendToBloc(ConnectToLocalStorageMarkEvent());
      _sendToBloc(StartListenSyncedUserMarkEvent());

      _searchTextController.addListener(() {
        _sendToBloc(EnterTextSearchMarkEvent(text: _searchTextController.text));
      });

      context.read<MarkBloc>().stream.listen((state) {
        if (state is ListMarkState) {
          setState(() => _marks = state.values);
        } else if (state is ConnectedToLocalStorageMarkState) {
          _sendToBloc(GetMarksFromLocalStorageMarkEvent());
        } else if (state is UserSyncedMarkState) {
          _sendToBloc(GetMarksFromCloudStorageMarkEvent());
        } else if (state is ErrorMarkState) {
          _showError(text: state.text);
        } else if (state is SearchingMarkState) {
          setState(() => _searchingMarkState = state);
        }
      });
    });
  }

  Widget _getAppBar() {
    if (_isSearching) {
      return SearchBar(
        textController: _searchTextController,
        onAddEmotion: () {
          _showMarkPickerScreen(
            onSelect: (emoji) {
              _searchTextController.text += emoji;
            },
          );
        },
        onCancel: () {
          _searchTextController.text = '';
          _sendToBloc(StopSearchMarkEvent());
        },
      );
    } else {
      return GestureDetector(
        onTap: () => _scrollToNow(),
        child: const Text(
          'Emodzen',
          style: TextStyle(color: Colors.black),
        ),
      );
    }
  }

  List<Widget>? _getActions() {
    if (_isSearching) {
      return null;
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        color: Colors.black,
        onPressed: () {
          _sendToBloc(StartSearchMarkEvent());
        },
      ),
      IconButton(
        icon: const Icon(Icons.settings),
        color: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: _getActions(),
        title: _getAppBar(),
        backgroundColor: Colors.white,
      ),
      body: _makeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showCupertinoModalBottomSheet(
            expand: false,
            context: context,
            builder: (context) => MarkCreatorScreen(
                onCreate: (data) {
                  _sendToBloc(
                    CreateMarkEvent(
                      dayIndex: _getNowDayIndex(),
                      note: data.text,
                      emoji: data.emoji,
                    ),
                  );
                },
              ),
          );
        },
        child: const Icon(Icons.mood),
      ),
    );
  }

  Widget _makeBody() {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: 99999999999,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (BuildContext context, int index) {
            final List<Mark> marksOfDay = _findMarksByDayIndex(index);
            final List<Widget> widgets = marksOfDay.map((mark) => _makeMarkWidget(mark)).toList();

            widgets.add(
              MarkWidget(
                item: '📝',
                onTap: () async => await _showMarkPickerScreen(onSelect: (emoji) async {
                  final note = await showTextInputDialog(
                    context: context,
                    message: emoji,
                    textFields: [
                      const DialogTextField(
                        initialText: '',
                        maxLines: 3,
                      )
                    ],
                  );
                  _sendToBloc(
                    CreateMarkEvent(
                      dayIndex: index,
                      note: note?.first ?? '',
                      emoji: emoji,
                    ),
                  );
                }),
                isHighlighted: true,
              ),
            );

            return Column(
              children: [
                Text(
                  _formatter.format(_getDateFromIndex(index)),
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
        // const Align(
        //   alignment: Alignment.bottomCenter,
        //   child: CreateMarkBar(
        //     textController: null,
        //   ),
        // ),
      ],
    );
  }

  Widget _makeMarkWidget(Mark mark) {
    final bool isHighlighted;
    if (_isSearching) {
      isHighlighted = _searchedValues.map((value) => value.uuid).contains(mark.uuid);
    } else {
      isHighlighted = true;
    }
    return MarkWidget(
      item: mark.emoji,
      onTap: () => showOkAlertDialog(
        title: mark.emoji,
        message: mark.note,
        context: context,
      ),
      onLongPress: () async => await _showMarkOptionsActionSheet(context, mark),
      isHighlighted: isHighlighted,
    );
  }

  _showMarkOptionsActionSheet(BuildContext context, Mark item) async {
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
      _sendToBloc(DeleteMarkEvent(uuid: item.uuid));
    } else if (result == 'copy_to_now_key') {
      await _copyToNow(context, item);
    }
  }

  _copyToNow(BuildContext context, Mark item) async {
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
    if (note != null) {
      _sendToBloc(
        CreateMarkEvent(
          dayIndex: _getNowDayIndex(),
          note: note.first,
          emoji: item.emoji,
        ),
      );
    }
  }

  _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkPickerScreen(onSelect: onSelect),
    );
  }

  DateTime _getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(_millisecondsInDay * index);

  List<Mark> _findMarksByDayIndex(int index) =>
      _marks.where((item) => index == item.dayIndex).sortedBy((it) => it.sortIndex).toList();

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

  void _sendToBloc(MarkEvent event) {
    context.read<MarkBloc>().add(event);
  }

  void _showError({required String text}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // TODO: Move to bloc with new action.

  int _getNowDayIndex() => _getDayIndex(DateTime.now());

  int _getDayIndex(DateTime date) =>
      (date.millisecondsSinceEpoch + date.timeZoneOffset.inMilliseconds) ~/ _millisecondsInDay;
}
