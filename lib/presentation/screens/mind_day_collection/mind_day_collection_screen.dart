import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:keklist/presentation/core/widgets/overscroll_listener.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/mind_chat_discussion/mind_chat_discussion_screen.dart';
import 'package:keklist/presentation/screens/mind_creator_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/presentation/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/screens/mind_info/mind_info_screen.dart';
import 'package:keklist/presentation/screens/mind_one_emoji_collection/mind_one_emoji_collection.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:keklist/domain/services/entities/mind.dart';

final class MindDayCollectionScreen extends StatefulWidget {
  final int initialDayIndex;
  final MindOperationError? initialError;
  final Iterable<Mind> allMinds;

  const MindDayCollectionScreen({
    super.key,
    required this.allMinds,
    required this.initialDayIndex,
    this.initialError,
  });

  @override
  // ignore: no_logic_in_create_state
  State<MindDayCollectionScreen> createState() => _MindDayCollectionScreenState(
        dayIndex: initialDayIndex,
        allMinds: allMinds.sortedBySortIndex(),
      );
}

final class _MindDayCollectionScreenState extends State<MindDayCollectionScreen> with DisposeBag {
  int dayIndex;
  final List<Mind> allMinds;

  final ScrollController _scrollController = ScrollController();

  List<Mind> get _dayMinds => MindUtils.findMindsByDayIndex(
        dayIndex: dayIndex,
        allMinds: allMinds,
      );

  Map<String, List<Mind>> get _mindIdsToChildren => MindUtils.convertToMindChildren(minds: allMinds);

  bool _isMindContentVisible = false;
  Mind? _editableMind;

  _MindDayCollectionScreenState({
    required this.dayIndex,
    required this.allMinds,
  });

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialError != null) {
        _handleError(widget.initialError!);
      }
    });

    subscribeTo<MindBloc>(onNewState: (state) async {
      if (state is MindList) {
        setState(() {
          allMinds
            ..clear()
            ..addAll(state.values.sortedBySortIndex());
        });
      } else if (state is MindOperationError) {
        _handleError(state);
      }
    })?.disposed(by: this);

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsDataState) {
        setState(() {
          _isMindContentVisible = state.settings.isMindContentVisible;
        });
      }
    })?.disposed(by: this);

    sendEventTo<SettingsBloc>(SettingsGet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        onPressed: () => _showMindCreator(),
        label: const Text(
          'Create',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        enableFeedback: true,
      ),
      appBar: AppBar(
        title: Text(DateFormatters.fullDateFormat.format(MindUtils.getDateFromDayIndex(dayIndex))),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final int? selectedDayIndex = await _showDateSwitcherToNewDay();
              if (selectedDayIndex == null) {
                return;
              }
              _switchToDayIndex(selectedDayIndex);
            },
          ),
          IconButton(
            icon: BoolWidget(
              condition: _isMindContentVisible,
              trueChild: const Icon(Icons.visibility_off_outlined),
              falseChild: const Icon(Icons.visibility),
            ),
            onPressed: () => _changeContentVisibility(),
          ),
        ],
      ),
      body: OverscrollListener(
        onOverscrollTopPointerUp: () => _switchToDayIndex(dayIndex - 1),
        onOverscrollBottomPointerUp: () => _switchToDayIndex(dayIndex + 1),
        onOverscrollTop: () => _vibrate(),
        onOverscrollBottom: () => _vibrate(),
        overscrollOffset: 150.0,
        childScrollController: _scrollController,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 150),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: MindMonologListWidget(
            minds: _dayMinds,
            onTap: (Mind mind) => _showMindInfo(mind),
            onOptions: (Mind mind) => _showActions(context, mind),
            mindIdsToChildren: _mindIdsToChildren,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _changeContentVisibility() {
    HapticFeedback.mediumImpact();
    sendEventTo<SettingsBloc>(SettingsChangeMindContentVisibility(isVisible: !_isMindContentVisible));
  }

  void _handleError(MindOperationError error) {
    // TODO: handle error if needed
  }

  Future<int?> _showDateSwitcherToNewDay() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [
        MindUtils.getDateFromDayIndex(this.dayIndex),
      ],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    final DateTime? selectedDateTime = dates?.firstOrNull;
    if (selectedDateTime == null) {
      return null;
    }

    final int dayIndex = MindUtils.getDayIndex(from: selectedDateTime);
    return dayIndex;
  }

  void _showMindInfo(Mind mind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MindInfoScreen(
          rootMind: mind,
          allMinds: allMinds,
        ),
      ),
    );
  }

  void _switchToDayIndex(int dayIndex) {
    _scrollController.jumpTo(0);
    setState(() {
      this.dayIndex = dayIndex;
    });
  }

  void _vibrate() {
    Haptics.vibrate(HapticsType.heavy);
  }

  // TODO: extract to some navigator

  void _showActions(BuildContext context, Mind mind) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (ActionModel.chatWithAI(), () => _showChatDiscussionScreen(mind: mind)),
          (ActionModel.edit(), () => _editMind(mind)),
          (ActionModel.switchDay(), () => _updateMindDay(mind)),
          (ActionModel.showAll(), () => _showAllMinds(mind)),
          (ActionModel.delete(), () => _removeMind(mind)),
        ],
      ),
    );
  }

  void _showChatDiscussionScreen({required Mind mind}) async {
    Navigator.of(mountedContext!).push(
      MaterialPageRoute(
        builder: (_) => MindChatDiscussionScreen(
          rootMind: mind,
          allMinds: allMinds,
        ),
      ),
    );
  }

  void _editMind(Mind mind) {
    _editableMind = mind;
    _showMindCreator(
      initialText: mind.note,
      initialEmoji: mind.emoji,
    );
  }

  Future<void> _updateMindDay(Mind mind) async {
    final int? switchedDay = await _showDateSwitcherToNewDay();
    if (switchedDay != null) {
      final List<Mind> switchedDayMinds = MindUtils.findMindsByDayIndex(
        dayIndex: switchedDay,
        allMinds: allMinds,
      );
      final int sortIndex = (switchedDayMinds.map((mind) => mind.sortIndex).maxOrNull ?? -1) + 1;
      final Mind newMind = mind.copyWith(dayIndex: switchedDay, sortIndex: sortIndex);
      sendEventTo<MindBloc>(MindEdit(mind: newMind));
    }
  }

  void _showAllMinds(Mind mind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MindOneEmojiCollectionScreen(
          emoji: mind.emoji,
          allMinds: allMinds,
        ),
      ),
    );
  }

  void _removeMind(Mind mind) {
    sendEventTo<MindBloc>(MindDelete(mind: mind));
  }

  void _showMindCreator({String? initialText, String? initialEmoji}) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (_) {
        return MindCreatorScreen(
          buttonIcon: initialEmoji == null ? const Icon(Icons.add) : const Icon(Icons.edit),
          buttonText: initialEmoji == null ? 'Create' : 'Edit',
          initialEmoji: initialEmoji,
          initialText: initialText,
          onDone: (String text, String emoji) {
            if (_editableMind == null) {
              final MindCreate event = MindCreate(
                dayIndex: dayIndex,
                note: text,
                emoji: emoji,
                rootId: null,
              );
              sendEventTo<MindBloc>(event);
            } else {
              final Mind mindForEdit = _editableMind!.copyWith(
                note: text,
                emoji: emoji,
              );
              sendEventTo<MindBloc>(MindEdit(mind: mindForEdit));
              _editableMind = null;
            }
          },
        );
      },
    );
  }
}
