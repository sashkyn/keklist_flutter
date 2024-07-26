import 'dart:async';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blur/blur.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/widgets/sensitive_widget.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/digest/mind_universal_list_screen.dart';
import 'package:keklist/presentation/screens/insights/insights_screen.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/mind_collection_empty_day_widget.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/mind_row_widget.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/mind_search_result_widget.dart';
import 'package:keklist/presentation/screens/mind_info/mind_info_screen.dart';
import 'package:keklist/presentation/screens/settings/settings_screen.dart';
import 'package:keklist/presentation/screens/web_page/web_page_screen.dart';
import 'package:keklist/presentation/core/widgets/rounded_container.dart';
import 'package:keklist/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/screens/mind_picker/mind_picker_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:uuid/uuid.dart';
part 'local_widgets/search_app_bar/search_app_bar.dart';
part 'local_widgets/app_bar/mind_collection_app_bar.dart';
part 'local_widgets/body/mind_collection_body.dart';
part 'local_widgets/body/mind_collection_demo_body.dart';

final class MindCollectionScreen extends StatefulWidget {
  const MindCollectionScreen({super.key});

  @override
  State<MindCollectionScreen> createState() => _MindCollectionScreenState();
}

final class _MindCollectionScreenState extends KekWidgetState<MindCollectionScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  Map<int, Iterable<Mind>> _mindsByDayIndex = {};
  SettingsDataState? _settingsDataState;
  MindSearching? _searchingMindState;

  bool _isDemoMode = false;

  bool get _isOfflineMode => _settingsDataState?.settings.isOfflineMode ?? false;
  bool get _shouldShowTitles => _settingsDataState?.settings.shouldShowTitles ?? true;

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

      subscribeTo<SettingsBloc>(onNewState: (state) {
        switch (state) {
          case SettingsDataState settingsDataState:
            _settingsDataState = settingsDataState;
            if (settingsDataState.settings.isOfflineMode) {
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
              falseChild: _MindCollectionAppBar(
                isOfflineMode: _isOfflineMode,
                isUpdating: _updating,
                onSearch: () => sendEventTo<MindBloc>(MindStartSearch()),
                onTitle: () => _scrollToNow(),
                onCalendar: () => _showCalendarActions(),
                onSettings: () => _showSettings(),
                onInsights: () => _showInsights(),
                onOfflineMode: () {
                  print('heheh');
                },
              )),
        ),
      ),
      body: BoolWidget(
        condition: _isDemoMode,
        trueChild: _MindCollectionDemoBody(),
        falseChild: _MindCollectionBody(
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
          shouldShowTitles: _shouldShowTitles,
        ),
      ),
      resizeToAvoidBottomInset: false,
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
    if (_isDemoMode) {
      return;
    }
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

  Future<void> _showDatePeriod() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDayOfWeek: 1,
        calendarType: CalendarDatePicker2Type.range,
      ),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.length < 2) {
      return;
    }

    final int startDayIndex = MindUtils.getDayIndex(from: dates[0]!);
    final int endDayIndex = MindUtils.getDayIndex(from: dates[1]!);

    if (mountedContext == null) {
      return;
    }

    Navigator.push(
      mountedContext!,
      MaterialPageRoute(
        builder: (context) {
          bool filterFunction(mind) => mind.dayIndex >= startDayIndex && mind.dayIndex <= endDayIndex;
          return MindUniversalListScreen(
            allMinds: _minds,
            filterFunction: filterFunction,
            title: 'Digest (${_minds.where(filterFunction).length} minds)',
            emptyStateMessage: 'No minds in selected period',
            onSelectMind: (mind) => _showMindInfo(mind),
          );
        },
      ),
    );
  }

  void _showCalendarActions() {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (ActionModel.goToDate(), () => _showDateSwitcher()),
          (ActionModel.showDigestForPeriod(), () => _showDatePeriod()),
        ],
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _showInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InsightsScreen(),
      ),
    );
  }

  void _cancelSearch() {
    _searchTextController.clear();
    sendEventTo<MindBloc>(MindStopSearch());
    WidgetsBinding.instance.addPostFrameCallback((_) async => _jumpToNow());
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

  void _showMindInfo(Mind mind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MindInfoScreen(
          rootMind: mind,
          allMinds: _minds,
        ),
      ),
    );
  }
}
