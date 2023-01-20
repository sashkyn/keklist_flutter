import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blur/blur.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';
import 'package:zenmode/blocs/mind_bloc/mind_bloc.dart';
import 'package:zenmode/screens/auth/auth_screen.dart';
import 'package:zenmode/screens/mark_collection/create_mark_bar.dart';
import 'package:zenmode/screens/mark_collection/search_bar.dart';
import 'package:zenmode/screens/mark_creator/mark_creator_screen.dart';
import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/screens/settings/settings_screen.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/typealiases.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zenmode/widgets/mark_widget.dart';

class MindCollectionScreen extends StatefulWidget {
  const MindCollectionScreen({Key? key}) : super(key: key);

  @override
  State<MindCollectionScreen> createState() => _MindCollectionScreenState();
}

class _MindCollectionScreenState extends State<MindCollectionScreen> with TickerProviderStateMixin {
  static const int _millisecondsInDay = 1000 * 60 * 60 * 24;
  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  MindSearching? _searchingMindState;
  MindSuggestions? _suggestionsMarkState;

  late int _dayIndexToCreateMark = _getNowDayIndex();
  bool _createMindBottomBarIsVisible = false;

  bool _isDemoMode = false;
  late AnimationController _demoScrollingAnimationController;

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);
  final FocusNode _createMarkFocusNode = FocusNode();
  String _selectedEmoji = Emoji.all().first.char;

  // NOTE: Состояние SearchBar.
  final TextEditingController _searchTextController = TextEditingController(text: null);

  bool get _isSearching => _searchingMindState != null && _searchingMindState!.enabled;
  Iterable<Mind> get _searchedMinds => _isSearching ? _searchingMindState!.filteredValues : [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();

      _sendToMarkBloc(MindGetList());

      // NOTE: Слежение за полем ввода поиска при изменении его значения.
      _searchTextController.addListener(() {
        _sendToMarkBloc(MindEnterSearchText(text: _searchTextController.text));
      });

      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        _sendToMarkBloc(MindChangeCreateText(text: _createMarkEditingController.text));
      });

      context.read<MindBloc>().stream.listen((state) {
        if (state is MindListState) {
          setState(() => _minds = state.values);
        } else if (state is MindError) {
          _showError(text: state.text);
        } else if (state is MindSearching) {
          setState(() => _searchingMindState = state);
        } else if (state is MindSuggestions) {
          setState(() {
            _suggestionsMarkState = state;
          });
        }
      });

      context.read<AuthBloc>().stream.listen((state) async {
        if (state is AuthLoggedIn) {
          _disableDemoMode();
          _sendToMarkBloc(MindGetList());
        } else if (state is AuthLogouted) {
          _enableDemoMode();
          _sendToMarkBloc(MindResetStorage());
        } else if (state is AuthCurrentStatus && !state.isLoggedIn) {
          _enableDemoMode();
          await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => const AuthScreen(),
            isDismissible: false,
            enableDrag: false,
          );
        }
      });
      context.read<AuthBloc>().add(AuthGetStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _makeAppBar(),
      body: _makeBody(),
    );
  }

  AppBar? _makeAppBar() {
    if (_isDemoMode) {
      return null;
    }

    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: _makeAppBarActions(),
      title: _makeAppBarTitle(),
      backgroundColor: Colors.white,
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
          _searchTextController.clear();
          _sendToMarkBloc(MindStopSearch());
        },
      );
    } else {
      return GestureDetector(
        onTap: () => _scrollToNow(),
        child: const Text(
          'Minds',
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
            _createMindBottomBarIsVisible = false;
            _sendToMarkBloc(MindStartSearch());
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
    final Widget scrollablePositionedList = ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(top: 16.0),
      itemCount: 99999999999,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (BuildContext context, int groupIndex) {
        final List<Widget> mindWidgets = [];
        if (_isDemoMode) {
          final random = Random();

          mindWidgets.addAll(
            List.generate(
              15,
              (index) {
                final randomEmoji = Emoji.all()[random.nextInt(Emoji.all().length - 1)].char;
                return Mind(
                  emoji: randomEmoji,
                  creationDate: 0,
                  note: '',
                  dayIndex: 0,
                  id: const Uuid().v4(),
                  sortIndex: 0,
                );
              },
            ).map((randomMark) => _makeMarkWidget(randomMark)).toList(),
          );
        } else {
          final List<Mind> mindsOfDay = _findMarksByDayIndex(groupIndex);
          final List<Widget> realMindWidgets = mindsOfDay.map((mark) => _makeMarkWidget(mark)).toList();
          mindWidgets.addAll(realMindWidgets);

          mindWidgets.add(
            MindWidget(
              item: '📝',
              onTap: () {
                setState(() {
                  _createMindBottomBarIsVisible = true;
                  _scrollToDayIndex(groupIndex);
                  _dayIndexToCreateMark = groupIndex;
                  _createMarkFocusNode.requestFocus();
                });
              },
              isHighlighted: true,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatter.format(_getDateFromIndex(groupIndex)),
              style: TextStyle(fontWeight: groupIndex == _getNowDayIndex() ? FontWeight.bold : FontWeight.normal),
            ),
            // TODO: поменять на non-scrollable grid
            GridView.count(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 5,
              children: mindWidgets,
            ),
          ],
        );
      },
    );
    return Stack(
      children: [
        GestureDetector(
          onPanDown: (details) {
            if (_createMarkFocusNode.hasFocus) {
              setState(() {
                _createMindBottomBarIsVisible = false;
                _hideKeyboard();
              });
            }
          },
          child: _isDemoMode
              ? Blur(
                  blur: 3,
                  blurColor: Colors.transparent,
                  colorOpacity: 0.2,
                  child: scrollablePositionedList,
                )
              : scrollablePositionedList,
        ),
        Visibility(
          visible: _createMindBottomBarIsVisible,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: CreateMindBar(
                  focusNode: _createMarkFocusNode,
                  textEditingController: _createMarkEditingController,
                  onKek: (CreateMarkData data) {
                    setState(() {
                      _suggestionsMarkState = null;
                      _createMarkEditingController.text = '';
                    });
                    _sendToMarkBloc(
                      MindCreate(
                        dayIndex: _dayIndexToCreateMark,
                        note: data.text,
                        emoji: data.emoji,
                      ),
                    );
                    _hideKeyboard();
                    _createMindBottomBarIsVisible = false;
                  },
                  suggestionMinds: _suggestionsMarkState?.suggestionMarks ?? [],
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
    );
  }

  Widget _makeMarkWidget(Mind mark) {
    final bool isHighlighted;
    if (_isSearching) {
      isHighlighted = _searchedMinds.map((value) => value.id).contains(mark.id);
    } else {
      isHighlighted = true;
    }
    return MindWidget(
      item: mark.emoji,
      onTap: () => showOkAlertDialog(
        title: mark.emoji,
        message: mark.note,
        context: context,
      ),
      onLongPress: () async => await _showMarkOptionsActionSheet(mark),
      isHighlighted: isHighlighted,
    );
  }

  _showMarkOptionsActionSheet(Mind item) async {
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
      _sendToMarkBloc(MindDelete(uuid: item.id));
    } else if (result == 'copy_to_now_key') {
      await _copyToNow(item);
    }
  }

  _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkPickerScreen(onSelect: onSelect),
    );
  }

  _copyToNow(Mind item) async {
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
      _sendToMarkBloc(
        MindCreate(
          dayIndex: _getNowDayIndex(),
          note: note.first,
          emoji: item.emoji,
        ),
      );
    }
  }

  DateTime _getDateFromIndex(int index) => DateTime.fromMillisecondsSinceEpoch(_millisecondsInDay * index);

  List<Mind> _findMarksByDayIndex(int index) =>
      _minds.where((item) => index == item.dayIndex).mySortedBy((it) => it.sortIndex).toList();

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

  void _sendToMarkBloc(MindEvent event) {
    context.read<MindBloc>().add(event);
  }

  void _showError({required String text}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  int _getNowDayIndex() => _getDayIndex(DateTime.now());

  int _getDayIndex(DateTime date) =>
      (date.millisecondsSinceEpoch + date.timeZoneOffset.inMilliseconds) ~/ _millisecondsInDay;

  // NOTE: Demo режим для авторизации

  void _enableDemoMode() {
    setState(() {
      _isDemoMode = true;
    });
    int initialIndex = _getNowDayIndex();
    _demoScrollingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          initialIndex++;
          _itemScrollController.scrollTo(
            index: initialIndex,
            alignment: 0.015,
            duration: const Duration(milliseconds: 2100),
          );
          _demoScrollingAnimationController.forward(from: 0);
        }
      });
    _demoScrollingAnimationController.forward();
  }

  void _disableDemoMode() {
    _isDemoMode = false;
    _demoScrollingAnimationController.stop();
    _demoScrollingAnimationController.dispose();
    _jumpToNow();
  }
}
