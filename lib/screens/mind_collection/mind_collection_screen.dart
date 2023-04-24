import 'dart:async';
import 'dart:math';

import 'package:blur/blur.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_collection_empty_day_widget.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_search_result_widget.dart';
import 'package:rememoji/screens/web_page/web_page_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/screens/auth/auth_screen.dart';
import 'package:rememoji/screens/mind_collection/widgets/my_table.dart';
import 'package:rememoji/screens/mind_collection/widgets/search_bar.dart';
import 'package:rememoji/screens/mind_picker/mind_picker_screen.dart';
import 'package:rememoji/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:rememoji/screens/settings/settings_screen.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/typealiases.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:rememoji/widgets/bool_widget.dart';
import 'package:rememoji/widgets/mind_widget.dart';

class MindCollectionScreen extends StatefulWidget {
  const MindCollectionScreen({Key? key}) : super(key: key);

  @override
  State<MindCollectionScreen> createState() => _MindCollectionScreenState();
}

class _MindCollectionScreenState extends State<MindCollectionScreen> with DisposeBag {
  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  MindSearching? _searchingMindState;

  bool _isDemoMode = false;

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);

  // NOTE: Состояние SearchBar.
  final TextEditingController _searchTextController = TextEditingController(text: null);
  bool get _isSearching => _searchingMindState != null && _searchingMindState!.enabled;
  List<Mind> get _searchResults => _isSearching ? _searchingMindState!.resultValues : [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();

      _sendToMindBloc(MindGetList());

      // NOTE: Слежение за полем ввода поиска при изменении его значения.
      _searchTextController.addListener(() {
        _sendToMindBloc(MindEnterSearchText(text: _searchTextController.text));
      });

      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        BlocUtils.sendTo<MindBloc>(
          context: context,
          event: MindChangeCreateText(text: _createMarkEditingController.text),
        );
      });

      context.read<SettingsBloc>().stream.listen((state) async {
        if (state.needToShowWhatsNewOnStart) {
          await _showWhatsNew();
          if (context.mounted) {
            context.read<SettingsBloc>().add(SettingsWhatsNewShown());
          }
        }
      }).disposed(by: this);

      context.read<MindBloc>().stream.listen((state) {
        if (state is MindListState) {
          setState(() {
            _minds = state.values;
          });
        } else if (state is MindError) {
          _showError(text: state.text);
        } else if (state is MindSearching) {
          setState(() {
            _searchingMindState = state;
          });
        }
      }).disposed(by: this);

      context.read<AuthBloc>().stream.listen((state) async {
        if (state is AuthLoggedIn) {
          _disableDemoMode();
          _sendToMindBloc(MindGetList());
        } else if (state is AuthLogouted) {
          _enableDemoMode();
          _sendToMindBloc(MindResetStorage());
          // NOTE: возвращаемся к главному экрану при логауте.
          Navigator.of(context).popUntil((route) => route.isFirst);
          _showAuthBottomSheet();
        } else if (state is AuthCurrentStatus && !state.isLoggedIn) {
          _enableDemoMode();
          await _showAuthBottomSheet();
        }
      }).disposed(by: this);

      context.read<AuthBloc>().add(AuthGetStatus());
      context.read<SettingsBloc>().add(SettingsGet());
    });
  }

  Future<void> _showAuthBottomSheet() async {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AuthScreen(),
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> _showWhatsNew() {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (builder) {
        return WebPageScreen(
          title: 'Whats new?',
          initialUri: Uri.parse(KeklistConstants.whatsNewURL),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _makeAppBar(),
      body: _makeBody(),
      resizeToAvoidBottomInset: false,
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
    return BoolWidget(
      condition: _isSearching,
      trueChild: SearchBar(
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
          _sendToMindBloc(MindStopSearch());
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _jumpToNow();
          });
        },
      ),
      falseChild: GestureDetector(
        onTap: () => _scrollToNow(),
        child: const Text('Minds'),
      ),
    );
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
          _sendToMindBloc(MindStartSearch());
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

  late final random = Random();

  Widget _makeBody() {
    if (_isSearching) {
      return MindSearchResultListWidget(
        results: _searchResults,
        onPanDown: () => _hideKeyboard(),
      );
    }

    final Widget scrollablePositionedList = ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(top: 16.0),
      itemCount: 99999999999,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (BuildContext context, int groupDayIndex) {
        final List<Widget> mindWidgets = [];
        if (_isDemoMode) {
          mindWidgets.addAll(
            List.generate(
              15,
              (index) {
                final randomEmoji =
                    KeklistConstants.demoModeEmodjiList[random.nextInt(KeklistConstants.demoModeEmodjiList.length - 1)];
                return Mind(
                  emoji: randomEmoji,
                  creationDate: 0,
                  note: '',
                  dayIndex: 0,
                  id: const Uuid().v4(),
                  sortIndex: 0,
                );
              },
            )
                .map(
                  (randomMind) => MindWidget(item: randomMind.emoji).animate().fadeIn(),
                )
                .toList(),
          );
        } else {
          final List<Mind> mindsOfDay = _findMarksByDayIndex(groupDayIndex);
          final List<Widget> realMindWidgets = mindsOfDay.map((mind) => MindWidget(item: mind.emoji)).toList();
          mindWidgets.addAll(realMindWidgets);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18.0),
            _makeMindsTitleWidget(groupDayIndex),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MindDayCollectionScreen(
                      minds: _findMarksByDayIndex(groupDayIndex),
                      dayIndex: groupDayIndex,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10.0,
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  child: BoolWidget(
                    condition: mindWidgets.isEmpty,
                    trueChild: () {
                      if (groupDayIndex < _getNowDayIndex()) {
                        return MindCollectionEmptyDayWidget.past();
                      } else if (groupDayIndex > _getNowDayIndex()) {
                        return MindCollectionEmptyDayWidget.future();
                      } else {
                        return MindCollectionEmptyDayWidget.present();
                      }
                    }(),
                    falseChild: MyTable(widgets: mindWidgets),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
    return GestureDetector(
      onPanDown: (_) => _hideKeyboard(),
      child: BoolWidget(
        condition: _isDemoMode,
        trueChild: Blur(
          blur: 3,
          blurColor: Colors.transparent,
          colorOpacity: 0.2,
          child: scrollablePositionedList,
        ),
        falseChild: scrollablePositionedList,
      ),
    );
  }

  Text _makeMindsTitleWidget(int groupIndex) {
    return Text(
      _formatter.format(MindUtils.getDateFromIndex(groupIndex)),
      style: TextStyle(fontWeight: groupIndex == _getNowDayIndex() ? FontWeight.bold : FontWeight.normal),
    );
  }

  _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }

  List<Mind> _findMarksByDayIndex(int index) =>
      _minds.where((item) => index == item.dayIndex).mySortedBy((it) => it.sortIndex).toList();

  void _jumpToNow() {
    _itemScrollController.jumpTo(index: _getNowDayIndex());
  }

  FutureOr<void> _scrollToNow() => _scrollToDayIndex(_getNowDayIndex());

  FutureOr<void> _scrollToDayIndex(int dayIndex) {
    return _itemScrollController.scrollTo(
      index: dayIndex,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _sendToMindBloc(MindEvent event) {
    context.read<MindBloc>().add(event);
  }

  void _showError({required String text}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  int _getNowDayIndex() => MindUtils.getDayIndex(from: DateTime.now());

  // NOTE: Demo режим для авторизации

  Timer? _demoAutoScrollingTimer;

  void _enableDemoMode() async {
    setState(() => _isDemoMode = true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();
      int nextDayIndex = _getNowDayIndex() + 1;
      _demoAutoScrollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        _itemScrollController.scrollTo(
          index: nextDayIndex++,
          alignment: 0.015,
          duration: const Duration(milliseconds: 4100),
        );
      });
    });
  }

  @override
  void dispose() {
    _demoAutoScrollingTimer?.cancel();

    super.dispose();
  }

  void _disableDemoMode() {
    if (!_isDemoMode) {
      return;
    }

    _demoAutoScrollingTimer?.cancel();
    setState(() {
      _isDemoMode = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();
    });
  }
}
