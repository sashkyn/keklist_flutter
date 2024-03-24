import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:keklist/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/screens/actions/action_model.dart';
import 'package:keklist/screens/actions/actions_screen.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/core/helpers/bloc_utils.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:keklist/screens/mind_info/mind_info_screen.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// TODO: сделать пробелы в днях между
// TODO: переделать Monolog на ListView
// TODO: подсветить сегодня

final class MindOneEmojiCollectionScreen extends StatefulWidget {
  final String emoji;
  final Iterable<Mind> allMinds;

  const MindOneEmojiCollectionScreen({
    super.key,
    required this.emoji,
    required this.allMinds,
  });

  @override
  // ignore: no_logic_in_create_state
  State<MindOneEmojiCollectionScreen> createState() => _MindOneEmojiCollectionScreenState(
        emoji: emoji,
        allMinds: allMinds.sortedByFunction((e) => e.dayIndex).toList(),
      );
}

final class _MindOneEmojiCollectionScreenState extends State<MindOneEmojiCollectionScreen> with DisposeBag {
  final String emoji;
  final List<Mind> allMinds;

  List<Mind> get emojiMinds => MindUtils.findMindsByEmoji(
        emoji: emoji,
        allMinds: allMinds,
      ).sortedByFunction((e) => e.dayIndex);

  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  bool _hasFocus = false;
  Mind? _editableMind;

  final ScrollController _scrollController = ScrollController();

  _MindOneEmojiCollectionScreenState({
    required this.emoji,
    required this.allMinds,
  });

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _mindCreatorFocusNode.addListener(() {
        if (_hasFocus == _mindCreatorFocusNode.hasFocus) {
          return;
        }
        setState(() {
          _hasFocus = _mindCreatorFocusNode.hasFocus;
        });
      });

      // Скролим вниз сразу.
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    subscribeTo<MindBloc>(onNewState: (state) async {
      if (state is MindList) {
        setState(() {
          allMinds
            ..clear()
            ..addAll(state.values.sortedByFunction((e) => e.dayIndex));
        });
      } else if (state is MindOperationError) {
        _handleError(state);
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(emoji),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) {
              if (_mindCreatorFocusNode.hasFocus) {
                _hideKeyboard();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 150),
              controller: _scrollController,
              child: MindMonologListWidget(
                minds: emojiMinds,
                onTap: _showMindInfo,
                onOptions: _showActions,
                mindIdsToChildren: null,
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
                    placeholder: 'Append a mind...',
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        sendEventTo<MindBloc>(
                          MindCreate(
                            dayIndex: MindUtils.getTodayIndex(),
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
                    suggestionMinds: const [],
                    selectedEmoji: emoji,
                    onTapEmoji: () {},
                    doneTitle: 'DONE',
                    onTapCancelEdit: () {
                      _resetMindCreator();
                    },
                    onTapSuggestionEmoji: (_) {},
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

  void _showKeyboard() {
    _mindCreatorFocusNode.requestFocus();
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showActions(Mind mind) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (
            ActionModel.edit(),
            () {
              setState(() {
                _editableMind = mind;
                // _selectedEmoji = mind.emoji;
              });
              _createMindEditingController.text = mind.note;
              _mindCreatorFocusNode.requestFocus();
            }
          ),
          (
            ActionModel.switchDay(),
            () async {
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
          ),
          (ActionModel.delete(), () => sendEventTo<MindBloc>(MindDelete(mind: mind))),
        ],
      ),
    );
  }

  void _handleError(MindOperationError error) {
    if (error.notCompleted == MindOperationType.create) {
      final Mind? notCreatedMind = error.minds.firstOrNull;
      if (notCreatedMind == null) {
        return;
      }

      setState(() {
        _createMindEditingController.text = notCreatedMind.note;
        // _selectedEmoji = notCreatedMind.emoji;
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
        // _selectedEmoji = notEditedMind.emoji;
        _showKeyboard();
      });
    }
  }

  Future<int?> _showDateSwitcherToNewDay() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [
        MindUtils.getDateFromIndex(MindUtils.getTodayIndex()),
      ],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates?.firstOrNull == null) {
      return null;
    }

    final int dayIndex = MindUtils.getDayIndex(from: dates!.first!);
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
