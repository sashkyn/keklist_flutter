import 'dart:async';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blur/blur.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/screens/mind_collection/local_widgets/mind_collection_empty_day_widget.dart';
import 'package:keklist/screens/mind_collection/local_widgets/mind_row_widget.dart';
import 'package:keklist/screens/mind_collection/local_widgets/mind_search_result_widget.dart';
import 'package:keklist/screens/web_page/web_page_screen.dart';
import 'package:keklist/widgets/rounded_container.dart';
import 'package:keklist/blocs/auth_bloc/auth_bloc.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/constants.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/extensions/dispose_bag.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_picker/mind_picker_screen.dart';
import 'package:keklist/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:keklist/widgets/bool_widget.dart';
import 'package:uuid/uuid.dart';
part 'local_widgets/search_app_bar/search_app_bar.dart';
part 'local_widgets/app_bar/app_bar.dart';
part 'local_widgets/body/body.dart';
part 'local_widgets/body/demo_body.dart';

class MindCollectionScreen extends StatefulWidget {
  const MindCollectionScreen({super.key});

  @override
  State<MindCollectionScreen> createState() => _MindCollectionScreenState();
}

class _MindCollectionScreenState extends State<MindCollectionScreen> with DisposeBag {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  Map<int, List<Mind>> _mindsByDayIndex = {};
  SettingsDataState? _settings;
  MindSearching? _searchingMindState;

  bool _isDemoMode = false;

  bool get _isOfflineMode => _settings?.isOfflineMode ?? false;

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);

  // NOTE: Состояние SearchBar.
  final TextEditingController _searchTextController = TextEditingController(text: null);
  bool get _isSearching => _searchingMindState != null && _searchingMindState!.enabled;
  List<Mind> get _searchResults => _isSearching ? _searchingMindState!.resultValues : [];

  // NOTE: Payments.
  // final PaymentService _payementService = PaymentService();

  // NOTE: Состояние обновления с сервером.
  bool _updating = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToNow();

      // NOTE: Слежение за полем ввода поиска при изменении его значения.
      _searchTextController.addListener(() {
        sendEventTo<MindBloc>(
          MindEnterSearchText(text: _searchTextController.text),
        );
      });

      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        sendEventTo<MindBloc>(
          MindChangeCreateText(text: _createMarkEditingController.text),
        );
      });

      subscribeTo<SettingsBloc>(onNewState: (state) {
        switch (state) {
          case SettingsDataState settings:
            _settings = settings;
            if (settings.isOfflineMode) {
              setState(() => _updating = false);
            }
            sendEventTo<AuthBloc>(AuthGetStatus());
          case SettingsNeedToShowWhatsNew _:
            _showWhatsNew();
            sendEventTo<SettingsBloc>(SettingsWhatsNewShown());
        }
      })?.disposed(by: this);

      subscribeTo<MindBloc>(
        onNewState: (state) async {
          if (state is MindList) {
            setState(() {
              _minds = state.values;
              _mindsByDayIndex =
                  state.values.where((element) => element.rootId == null).groupListsBy((element) => element.dayIndex);
            });
          } else if (state is MindServerOperationStarted) {
            if (state.type == MindOperationType.fetch) {
              setState(() => _updating = true);
            }
            // INFO: запрос для виджета
            sendEventTo<MindBloc>(MindUpdateMobileWidgets());
          } else if (state is MindOperationCompleted) {
            if (state.type == MindOperationType.fetch) {
              setState(() => _updating = false);
            }
          } else if (state is MindOperationError) {
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              _showDayCollectionAndHandleError(state: state);
            }

            if (state.notCompleted == MindOperationType.fetch) {
              setState(() => _updating = false);
            }

            // TODO: сделать единый центр обработки блокирующих событий UI-ных
            // Показ ошибки.
            if (MindOperationType.values
                .where(
                  (element) => element != MindOperationType.uploadCachedData && element != MindOperationType.fetch,
                )
                .contains(state.notCompleted)) {
              showOkAlertDialog(
                context: context,
                title: 'Error',
                message: state.localizedString,
              );
            }
          } else if (state is MindSearching) {
            setState(() => _searchingMindState = state);
          }
        },
      )?.disposed(by: this);

      subscribeTo<AuthBloc>(onNewState: (state) {
        switch (state) {
          case AuthCurrentState state when (state.isLoggedIn || _isOfflineMode):
            _disableDemoMode();
            sendEventTo<MindBloc>(MindGetList());
          case AuthCurrentState state when !state.isLoggedIn:
            _enableDemoMode();
        }
      })?.disposed(by: this);

      sendEventTo<AuthBloc>(AuthGetStatus());
      sendEventTo<SettingsBloc>(SettingsGet());
      // sendEventTo<SettingsBloc>(SettingGetWhatsNew());
      //_payementService.initConnection();
    });
  }

  void _showDayCollectionAndHandleError({required MindOperationError state}) {
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
    cancelSubscriptions();

    super.dispose();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BoolWidget(
          condition: !_isDemoMode,
          falseChild: const SizedBox.shrink(),
          trueChild: BoolWidget(
              condition: _isSearching,
              trueChild: _SearchAppBar(
                searchTextController: _searchTextController,
                onSearchAddEmotion: () => _showMindPickerScreen(onSelect: (emoji) {
                  _searchTextController.text += emoji;
                }),
                onSearchCancel: () => _cancelSearch(),
              ),
              falseChild: _AppBar(
                isUpdating: _updating,
                onSearch: () => sendEventTo<MindBloc>(MindStartSearch()),
                onTitle: () => _scrollToNow(),
                onCalendar: () async => await _showDateSwitcher(),
              )),
        ),
      ),
      body: BoolWidget(
        condition: _isDemoMode,
        trueChild: _DemoBody(),
        falseChild: _Body(
          mindsByDayIndex: _mindsByDayIndex,
          isSearching: _isSearching,
          searchResults: _searchResults,
          hideKeyboard: _hideKeyboard,
          onTapToDay: (dayIndex) => _showDayCollectionScreen(
            groupDayIndex: dayIndex,
            initialError: null,
          ),
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          getNowDayIndex: _getNowDayIndex,
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void _showDayCollectionScreen({
    required int groupDayIndex,
    required MindOperationError? initialError,
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

  void _jumpToNow() {
    _itemScrollController.jumpTo(index: _getNowDayIndex());
  }

  Future<void> _scrollToNow() => _scrollToDayIndex(_getNowDayIndex());

  Future<void> _scrollToDayIndex(int dayIndex) {
    return _itemScrollController.scrollTo(
      index: dayIndex,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  int _getNowDayIndex() => MindUtils.getDayIndex(from: DateTime.now());

  void _enableDemoMode() {
    if (_isDemoMode) {
      return;
    }

    setState(() => _isDemoMode = true);
  }

  void _disableDemoMode() {
    if (!_isDemoMode) {
      return;
    }

    setState(() => _isDemoMode = false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpToNow();
    });
  }

  Future<void> _showDateSwitcher() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.isEmpty) {
      return;
    }

    final int dayIndex = MindUtils.getDayIndex(from: dates.first!);
    _scrollToDayIndex(dayIndex);
  }

  void _cancelSearch() {
    _searchTextController.clear();
    sendEventTo<MindBloc>(MindStopSearch());
    WidgetsBinding.instance.addPostFrameCallback((_) async => _jumpToNow());
  }
}
