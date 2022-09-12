import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:zenmode/blocs/mark_bloc/mark_bloc.dart';
import 'package:zenmode/screens/mark_collection/create_mark_bar.dart';
import 'package:zenmode/screens/mark_collection/search_bar.dart';
import 'package:zenmode/screens/mark_creator/mark_creator_screen.dart';
import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/screens/settings/settings_screen.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/typealiases.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  SuggestionsMarkState? _suggestionsMarkState;

  late int _dayIndexToCreateMark = _getNowDayIndex();
  bool _createMarkBottomBarIsVisible = false;

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);
  final FocusNode _createMarkFocusNode = FocusNode();
  String _selectedEmoji = Emoji.all().first.char;

  // NOTE: Состояние SearchBar.
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

      // NOTE: Слежение за полем ввода поиска при изменении его значения.
      _searchTextController.addListener(() {
        _sendToBloc(EnterTextSearchMarkEvent(text: _searchTextController.text));
      });

      // NOTE: Слежение за полем ввода в создании нового кека при изменении его значения.
      _createMarkEditingController.addListener(() {
        _sendToBloc(ChangeTextOfCreatingMarkEvent(text: _createMarkEditingController.text));
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
        } else if (state is SuggestionsMarkState) {
          setState(() {
            _suggestionsMarkState = state;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: _makeAppBarActions(),
        title: _makeAppBarTitle(),
        backgroundColor: Colors.white,
      ),
      body: _makeBody(),
    );
  }

  Widget _makeAppBarTitle() {
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
          'Zenmode',
          style: TextStyle(color: Colors.black),
        ),
      );
    }
  }

  List<Widget>? _makeAppBarActions() {
    if (_isSearching) {
      return null;
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        color: Colors.black,
        onPressed: () {
          setState(() {
            _createMarkBottomBarIsVisible = false;
            _sendToBloc(StartSearchMarkEvent());
          });
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

  Widget _makeBody() {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: (details) {
              if (_createMarkFocusNode.hasFocus) {
                setState(() {
                  _createMarkBottomBarIsVisible = false;
                  _hideKeyboard();
                });
              }
            },
            child: ScrollablePositionedList.builder(
              padding: const EdgeInsets.only(top: 16.0),
              itemCount: 99999999999,
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              itemBuilder: (BuildContext context, int groupIndex) {
                final List<Mark> marksOfDay = _findMarksByDayIndex(groupIndex);
                final List<Widget> widgets = marksOfDay.map((mark) => _makeMarkWidget(mark)).toList();

                widgets.add(
                  MarkWidget(
                    item: '📝',
                    onTap: () {
                      setState(() {
                        _createMarkBottomBarIsVisible = true;
                        _scrollToDayIndex(groupIndex);
                        _dayIndexToCreateMark = groupIndex;
                        _createMarkFocusNode.requestFocus();
                      });
                    },
                    isHighlighted: true,
                  ),
                );

                return Column(
                  children: [
                    Text(
                      _formatter.format(_getDateFromIndex(groupIndex)),
                      style:
                          TextStyle(fontWeight: groupIndex == _getNowDayIndex() ? FontWeight.bold : FontWeight.normal),
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
          ),
          Visibility(
            visible: _createMarkBottomBarIsVisible,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CreateMarkBar(
                    focusNode: _createMarkFocusNode,
                    textEditingController: _createMarkEditingController,
                    onKek: (CreateMarkData data) {
                      setState(() {
                        _suggestionsMarkState = null;
                        _createMarkEditingController.text = '';
                      });
                      _sendToBloc(
                        CreateMarkEvent(
                          dayIndex: _dayIndexToCreateMark,
                          note: data.text,
                          emoji: data.emoji,
                        ),
                      );
                      _hideKeyboard();
                      _createMarkBottomBarIsVisible = false;
                    },
                    suggestionMarks: _suggestionsMarkState?.suggestionMarks ?? [],
                    selectedEmoji: _selectedEmoji,
                    onSelectSuggestionEmoji: (String suggestionEmoji) {
                      setState(() => _selectedEmoji = suggestionEmoji);
                    },
                    onSearchEmoji: () {
                      _showMarkPickerScreen(
                        onSelect: (String emoji) => setState(() => _selectedEmoji = emoji),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkPickerScreen(onSelect: onSelect),
    );
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

  DateTime _getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(_millisecondsInDay * index);

  List<Mark> _findMarksByDayIndex(int index) =>
      _marks.where((item) => index == item.dayIndex).mySortedBy((it) => it.sortIndex).toList();

  void _jumpToNow() {
    _itemScrollController.jumpTo(
      index: _getNowDayIndex(),
      alignment: 0.015,
    );
  }

  void _scrollToNow() {
    _scrollToDayIndex(_getNowDayIndex());
  }

  void _scrollToDayIndex(int dayIndex) {
    _itemScrollController.scrollTo(
      index: dayIndex,
      alignment: 0.015,
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

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  // TODO: Move to bloc with new action.

  int _getNowDayIndex() => _getDayIndex(DateTime.now());

  int _getDayIndex(DateTime date) =>
      (date.millisecondsSinceEpoch + date.timeZoneOffset.inMilliseconds) ~/ _millisecondsInDay;
}
