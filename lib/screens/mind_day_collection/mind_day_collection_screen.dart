import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keklist/screens/mind_chat_discussion/mind_chat_discussion_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/screens/mind_day_collection/widgets/iconed_list/mind_iconed_list_widget.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/constants.dart';
import 'package:keklist/core/helpers/bloc_utils.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_info/mind_info_screen.dart';
import 'package:keklist/screens/mind_one_emoji_collection/mind_one_emoji_collection.dart';
import 'package:keklist/screens/mind_picker/mind_picker_screen.dart';
import 'package:keklist/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:keklist/core/widgets/bool_widget.dart';
import 'package:keklist/services/entities/mind.dart';

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

  // TODO: Перетащить стейт в бар
  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  String _selectedEmoji = Emoji.all().first.char;
  MindSuggestions? _mindSuggestions;
  bool _isMindContentVisible = false;
  bool _hasFocus = false;
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

      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMindEditingController.addListener(() {
        sendEventTo<MindBloc>(MindChangeCreateText(text: _createMindEditingController.text));
      });

      _mindCreatorFocusNode.addListener(() {
        if (_hasFocus == _mindCreatorFocusNode.hasFocus) {
          return;
        }
        setState(() {
          _hasFocus = _mindCreatorFocusNode.hasFocus;
        });
      });
    });

    subscribeTo<MindBloc>(onNewState: (state) async {
      if (state is MindList) {
        setState(() {
          allMinds
            ..clear()
            ..addAll(state.values.sortedBySortIndex());
        });
      } else if (state is MindSuggestions) {
        setState(() {
          _mindSuggestions = state;
        });
      } else if (state is MindOperationError) {
        _handleError(state);
      }
    })?.disposed(by: this);

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsDataState) {
        setState(() {
          _isMindContentVisible = state.isMindContentVisible;
        });
      }
    })?.disposed(by: this);

    sendEventTo<SettingsBloc>(SettingsGet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatters.fullDateFormat.format(MindUtils.getDateFromIndex(dayIndex))),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final int? selectedDayIndex = await _showDateSwitcherToNewDay();
              if (selectedDayIndex == null) {
                return;
              }
              setState(() {
                dayIndex = selectedDayIndex;
                _hideKeyboard();
                _scrollController.jumpTo(0);
              });
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
      body: Stack(
        children: [
          BoolWidget(
            condition: _isMindContentVisible,
            trueChild: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 150),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: BoolWidget(
                condition: _isMindContentVisible,
                trueChild: MindMonologListWidget(
                  minds: _dayMinds,
                  onTap: (Mind mind) => _showMindInfo(mind),
                  onOptions: (Mind mind) => _showMindOptionsActionSheet(mind),
                  mindIdsToChildren: _mindIdsToChildren,
                ),
                falseChild: MindIconedListWidget(
                  minds: _dayMinds,
                  onTap: (Mind mind) => showOkAlertDialog(
                    title: mind.emoji,
                    message: mind.note,
                    context: context,
                  ),
                  onLongTap: (Mind mind) => _showMindOptionsActionSheet(mind),
                  mindIdsToChildCount: null,
                ),
              ),
            ),
            falseChild: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 150),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SafeArea(
                child: MindIconedListWidget(
                  minds: _dayMinds,
                  onTap: (Mind mind) => _showMindInfo(mind),
                  onLongTap: (Mind mind) => _showMindOptionsActionSheet(mind),
                  mindIdsToChildCount: null,
                ),
              ),
            ),
          ),
          Stack(
            children: [
              // NOTE: Подложка для скрытия текста эмодзи.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: 90,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MindCreatorBottomBar(
                    editableMind: _editableMind,
                    focusNode: _mindCreatorFocusNode,
                    textEditingController: _createMindEditingController,
                    placeholder: 'Create a mind...',
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        sendEventTo<MindBloc>(
                          MindCreate(
                            dayIndex: dayIndex,
                            note: data.text,
                            emoji: data.emoji,
                            rootId: null,
                          ),
                        );
                      } else {
                        final Mind mindForEdit = _editableMind!.copyWith(
                          note: data.text,
                          emoji: data.emoji,
                        );
                        sendEventTo<MindBloc>(MindEdit(mind: mindForEdit));
                      }
                      _resetMindCreator();
                    },
                    suggestionMinds: _hasFocus ? _mindSuggestions?.values ?? [] : [],
                    selectedEmoji: _selectedEmoji,
                    onTapSuggestionEmoji: (String suggestionEmoji) {
                      setState(() {
                        _selectedEmoji = suggestionEmoji;
                      });
                    },
                    onTapEmoji: () {
                      _showEmojiPickerScreen(
                        onSelect: (String emoji) {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        },
                      );
                    },
                    doneTitle: 'DONE',
                    onTapCancelEdit: () {
                      _resetMindCreator();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _resetMindCreator() {
    setState(() {
      _editableMind = null;
      _createMindEditingController.text = '';
      _hideKeyboard();
    });
  }

  void _changeContentVisibility() {
    HapticFeedback.mediumImpact();
    sendEventTo<SettingsBloc>(SettingsChangeMindContentVisibility(isVisible: !_isMindContentVisible));
  }

  void _showKeyboard() {
    _mindCreatorFocusNode.requestFocus();
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showEmojiPickerScreen({required Function(String) onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }

  void _showMessageScreen({required Mind mind}) async {
    Navigator.of(mountedContext!).push(
      MaterialPageRoute(
        builder: (_) => MindChatDiscussionScreen(
          rootMind: mind,
          allMinds: allMinds,
        ),
      ),
    );
  }

  void _showMindOptionsActionSheet(Mind mind) async {
    final String? result = await showModalActionSheet(
      context: context,
      actions: [
        const SheetAction(
          icon: Icons.edit,
          label: 'Discuss with AI',
          key: 'discuss_with_ai',
        ),
        const SheetAction(
          icon: Icons.edit,
          label: 'Edit',
          key: 'edit_key',
        ),
        const SheetAction(
          icon: Icons.date_range,
          label: 'Switch day',
          key: 'switch_day_key',
        ),
        const SheetAction(
          icon: Icons.emoji_emotions,
          label: 'Show all',
          key: 'show_all_key',
        ),
        const SheetAction(
          icon: Icons.delete,
          label: 'Delete',
          key: 'remove_key',
          isDestructiveAction: true,
        ),
      ],
    );
    if (result == 'discuss_with_ai') {
      _showMessageScreen(mind: mind);
    } else if (result == 'remove_key') {
      sendEventTo<MindBloc>(MindDelete(uuid: mind.id));
    } else if (result == 'edit_key') {
      setState(() {
        _editableMind = mind;
        _selectedEmoji = mind.emoji;
      });
      _createMindEditingController.text = mind.note;
      _mindCreatorFocusNode.requestFocus();
    } else if (result == 'switch_day_key') {
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
    } else if (result == 'show_all_key') {
      if (mountedContext == null) {
        return;
      }

      Navigator.of(mountedContext!).push(
        MaterialPageRoute(
          builder: (_) => MindOneEmojiCollectionScreen(
            emoji: mind.emoji,
            allMinds: allMinds,
          ),
        ),
      );
    }
  }

  void _handleError(MindOperationError error) {
    if (error.notCompleted == MindOperationType.create) {
      final Mind? notCreatedMind = error.minds.firstOrNull;
      if (notCreatedMind == null) {
        return;
      }

      setState(() {
        _createMindEditingController.text = notCreatedMind.note;
        _selectedEmoji = notCreatedMind.emoji;
        _showKeyboard();
      });
    } else if (error.notCompleted == MindOperationType.edit) {
      final Mind? notEditedMind = error.minds.firstOrNull;
      if (notEditedMind == null) {
        return;
      }

      final Mind? oldMind = allMinds.firstWhereOrNull((Mind mind) => mind.id == notEditedMind.id);
      if (oldMind == null) {
        return;
      }
      setState(() {
        _editableMind = oldMind;
        _createMindEditingController.text = notEditedMind.note;
        _selectedEmoji = notEditedMind.emoji;
        _showKeyboard();
      });
    }
  }

  Future<int?> _showDateSwitcherToNewDay() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [
        MindUtils.getDateFromIndex(this.dayIndex),
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
    if (mountedContext == null) {
      return;
    }

    Navigator.of(mountedContext!).push(
      MaterialPageRoute(
        builder: (_) => MindInfoScreen(
          rootMind: mind,
          allMinds: allMinds,
        ),
      ),
    );
  }
}
