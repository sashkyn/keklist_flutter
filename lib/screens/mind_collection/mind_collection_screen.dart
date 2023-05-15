import 'dart:async';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blur/blur.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_collection_empty_day_widget.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_search_bar.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_search_result_widget.dart';
import 'package:rememoji/screens/web_page/web_page_screen.dart';
import 'package:rememoji/widgets/rounded_container.dart';
import 'package:uuid/uuid.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/screens/mind_collection/widgets/my_table.dart';
import 'package:rememoji/screens/mind_picker/mind_picker_screen.dart';
import 'package:rememoji/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:rememoji/services/entities/mind.dart';
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
  bool _isOfflineMode = false;

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);

  // NOTE: Состояние SearchBar.
  final TextEditingController _searchTextController = TextEditingController(text: null);
  bool get _isSearching => _searchingMindState != null && _searchingMindState!.enabled;
  List<Mind> get _searchResults => _isSearching ? _searchingMindState!.resultValues : [];

  // NOTE: Payments.
  // final PaymentService _payementService = PaymentService();

  // NOTE: Состояния обновления с сервером.
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();

      sendEventTo<MindBloc>(MindGetList());

      // NOTE: Слежение за полем ввода поиска при изменении его значения.
      _searchTextController.addListener(() {
        sendEventTo<MindBloc>(MindEnterSearchText(text: _searchTextController.text));
      });

      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        BlocUtils.sendEventTo<MindBloc>(
          context: context,
          event: MindChangeCreateText(text: _createMarkEditingController.text),
        );
      });

      subscribeTo<SettingsBloc>(onNewState: (state) async {
        if (state is SettingsDataState) {
          _isOfflineMode = state.isOfflineMode;
          if (state.isOfflineMode) {
            setState(() {
              _updating = false;
            });
          }
          sendEventTo<AuthBloc>(AuthGetCurrentStatus());
        } else if (state is SettingsWhatsNewState && state.needToShowWhatsNewOnStart) {
          await _showWhatsNew();
          sendEventTo<SettingsBloc>(SettingsWhatsNewShown());
        }
      })?.disposed(by: this);

      subscribeTo<MindBloc>(onNewState: (state) async {
        if (state is MindList) {
          setState(() {
            _minds = state.values;
          });
        } else if (state is MindServerOperationStarted) {
          if (state.type == MindOperationType.fetch) {
            setState(() => _updating = true);
          }
        } else if (state is MindOperationCompleted) {
          if (state.type == MindOperationType.fetch) {
            setState(() => _updating = false);
          }
        } else if (state is MindOperationNotCompleted) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            _showDayCollectionAndHandleError(state: state);
          }

          if (state.notCompleted == MindOperationType.fetch) {
            setState(() {
              _updating = false;
            });
          }

          // Показ ошибки.
          if (MindOperationType.values
              .where(
                (element) => element != MindOperationType.uploadCachedData && element != MindOperationType.fetch,
              )
              .contains(state.notCompleted)) {
            showOkAlertDialog(
              context: context,
              title: 'Error',
              message: state.toString(), // TODO: локализовать ошибку для пользователя
            );
          } else {
            // TODO: remove print
            print('MindOperationNotCompleted: ${state.toString()}');
          }
        } else if (state is MindSearching) {
          setState(() => _searchingMindState = state);
        }
      })?.disposed(by: this);

      subscribeTo<AuthBloc>(onNewState: (state) async {
        if (state is AuthLoggedIn || !_isOfflineMode) {
          _disableDemoMode();
          sendEventTo<MindBloc>(MindGetList());
        } else if (state is AuthLogouted && !_isOfflineMode ||
            state is AuthCurrentStatus && !state.isLoggedIn && !_isOfflineMode) {
          _enableDemoMode();
          sendEventTo<SettingsBloc>(SettingsNeedToShowAuth());
        }
      })?.disposed(by: this);

      sendEventTo<AuthBloc>(AuthGetCurrentStatus());
      sendEventTo<SettingsBloc>(SettingsGet());

      //_payementService.initConnection();
    });
  }

  void _showDayCollectionAndHandleError({required MindOperationNotCompleted state}) {
    if ([
      MindOperationType.create,
      MindOperationType.edit,
    ].contains(state.notCompleted)) {
      if (state.minds.isEmpty) {
        return;
      }
      _showDayCollectionScreen(
        groupDayIndex: state.minds.first.dayIndex,
        initialError: state,
      );
    }
  }

  @override
  void dispose() {
    _demoAutoScrollingTimer?.cancel();

    cancelSubscriptions();
    super.dispose();
  }

  // TODO: убрать в навигатор!

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

    if (_updating) {
      return AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: GestureDetector(
          onTap: () => _scrollToNow(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Updating'),
              SizedBox(width: 4),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      );
    } else {
      return AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: _makeAppBarActions(),
        title: _makeAppBarTitle(),
        backgroundColor: Colors.white,
      );
    }
  }

  Widget _makeAppBarTitle() {
    return BoolWidget(
      condition: _isSearching,
      trueChild: MindSearchBar(
        textController: _searchTextController,
        onAddEmotion: () {
          _showMindPickerScreen(
            onSelect: (emoji) {
              _searchTextController.text += emoji;
            },
          );
        },
        onCancel: () {
          _searchTextController.clear();
          sendEventTo<MindBloc>(MindStopSearch());
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
        icon: const Icon(Icons.calendar_month),
        color: Colors.black,
        onPressed: () async => await _showDateSwitcher(),
      ),
      IconButton(
        icon: const Icon(Icons.search),
        color: Colors.black,
        onPressed: () => sendEventTo<MindBloc>(MindStartSearch()),
      ),
    ];
  }

  late final _demoModeRandom = Random();

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
                final randomEmoji = KeklistConstants
                    .demoModeEmodjiList[_demoModeRandom.nextInt(KeklistConstants.demoModeEmodjiList.length - 1)];
                return Mind(
                  emoji: randomEmoji,
                  creationDate: DateTime.now(),
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
          final List<Mind> mindsOfDay = _findMindsByDayIndex(groupDayIndex);
          final List<Widget> realMindWidgets = mindsOfDay
              .mySortedBy(
                (e) => e.sortIndex,
              )
              .map((mind) => MindWidget(item: mind.emoji))
              .toList();
          mindWidgets.addAll(realMindWidgets);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18.0),
            Text(
              _formatter.format(MindUtils.getDateFromIndex(groupDayIndex)),
              style: TextStyle(fontWeight: groupDayIndex == _getNowDayIndex() ? FontWeight.bold : FontWeight.normal),
            ),
            const SizedBox(height: 4.0),
            GestureDetector(
              onTap: () {
                _showDayCollectionScreen(
                  groupDayIndex: groupDayIndex,
                  initialError: null,
                );
              },
              child: RoundedContainer(
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

  void _showDayCollectionScreen({
    required int groupDayIndex,
    required MindOperationNotCompleted? initialError,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MindDayCollectionScreen(
          allMinds: _minds,
          initialDayIndex: groupDayIndex,
          initialError: initialError,
        ),
      ),
    );
  }

  void _showMindPickerScreen({required Function(String) onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }

  List<Mind> _findMindsByDayIndex(int index) {
    return MindUtils.findMindsByDayIndex(dayIndex: index, allMinds: _minds);
  }

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

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  int _getNowDayIndex() => MindUtils.getDayIndex(from: DateTime.now());

  // NOTE: Demo режим для авторизации

  Timer? _demoAutoScrollingTimer;

  void _enableDemoMode() async {
    if (_isDemoMode) {
      return;
    }

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

  Future<void> _showDateSwitcher() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [],
      config: CalendarDatePicker2WithActionButtonsConfig(),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.isEmpty || dates.first == null) {
      return;
    }

    final int dayIndex = MindUtils.getDayIndex(from: dates.first!);
    _scrollToDayIndex(dayIndex);
  }

  void _disableDemoMode() {
    if (!_isDemoMode) {
      return;
    }

    _demoAutoScrollingTimer?.cancel();
    setState(() => _isDemoMode = false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _demoAutoScrollingTimer?.cancel();
      _jumpToNow();
    });
  }
}
