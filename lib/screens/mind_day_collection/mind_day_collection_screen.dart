import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/iconed_list/mind_iconed_list_widget.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:rememoji/widgets/text_field_alert.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/helpers/extensions/state_extensions.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/screens/mind_creator/mind_creator_screen.dart';
import 'package:rememoji/screens/mind_picker/mind_picker_screen.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:rememoji/widgets/bool_widget.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/typealiases.dart';

class MindDayCollectionScreen extends StatefulWidget {
  final int dayIndex;
  final Iterable<Mind> allMinds;

  const MindDayCollectionScreen({
    super.key,
    required this.allMinds,
    required this.dayIndex,
  });

  @override
  // ignore: no_logic_in_create_state
  State<MindDayCollectionScreen> createState() => _MindDayCollectionScreenState(
        dayIndex: dayIndex,
        allMinds: allMinds.toList(),
      );
}

class _MindDayCollectionScreenState extends State<MindDayCollectionScreen> with DisposeBag {
  int dayIndex;
  final List<Mind> allMinds;

  List<Mind> get dayMinds => MindUtils.findMindsByDayIndex(
        dayIndex: dayIndex,
        allMinds: allMinds,
      );

  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();

  String _selectedEmoji = Emoji.all().first.char;
  MindSuggestions? _mindSuggestions;
  bool _isMindContentVisible = false;
  bool _hasFocus = false;

  _MindDayCollectionScreenState({
    required this.dayIndex,
    required this.allMinds,
  });

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        BlocUtils.sendTo<MindBloc>(
          context: context,
          event: MindChangeCreateText(text: _createMarkEditingController.text),
        );
      });

      // TODO: сделать чтобы по перевороту работало а не по тряске, а то работает удовлетворительно
      // NOTE: По тряске телефона скрываем/показываем текст эмодзи.
      // final ShakeDetector shakeDetector = ShakeDetector.autoStart(
      //   shakeThresholdGravity: 5.0,
      //   shakeSlopTimeMS: 1300,
      //   onPhoneShake: () => _changeContentVisibility(),
      // );
      // shakeDetector.streamSubscription?.disposed(by: this);

      _mindCreatorFocusNode.addListener(() {
        if (_hasFocus == _mindCreatorFocusNode.hasFocus) {
          return;
        }
        setState(() {
          _hasFocus = _mindCreatorFocusNode.hasFocus;
        });
      });
    });

    context.read<MindBloc>().stream.listen((state) {
      if (state is MindListState) {
        setState(() {
          allMinds
            ..clear()
            ..addAll(state.values);
        });
      } else if (state is MindSuggestions) {
        setState(() {
          _mindSuggestions = state;
        });
      }
    }).disposed(by: this);

    context.read<SettingsBloc>().stream.listen((state) {
      setState(() {
        _isMindContentVisible = state.isMindContentVisible;
      });
    }).disposed(by: this);

    BlocUtils.sendTo<SettingsBloc>(
      context: context,
      event: SettingsGet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatters.fullDateFormat.format(MindUtils.getDateFromIndex(dayIndex))),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async => await _showDateSwitcher(),
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
          GestureDetector(
            onPanDown: (_) {
              if (_mindCreatorFocusNode.hasFocus) {
                setState(() {
                  _hideKeyboard();
                });
              }
            },
            child: BoolWidget(
              condition: _isMindContentVisible,
              trueChild: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: BoolWidget(
                      condition: _isMindContentVisible,
                      trueChild: MindMonologListWidget(
                        minds: dayMinds,
                        onTap: (Mind mind) => _showMarkOptionsActionSheet(mind),
                      ),
                      falseChild: MindIconedListWidget(
                        minds: dayMinds,
                        onTap: (Mind mind) => showOkAlertDialog(
                          title: mind.emoji,
                          message: mind.note,
                          context: context,
                        ),
                        onLongTap: (Mind mind) => _showMarkOptionsActionSheet(mind),
                      ),
                    ),
                  ),
                ],
              ),
              falseChild: SingleChildScrollView(
                child: MindIconedListWidget(
                  minds: dayMinds,
                  onTap: (Mind mind) => showOkAlertDialog(
                    title: mind.emoji,
                    message: mind.note,
                    context: context,
                  ),
                  onLongTap: (Mind mind) => _showMarkOptionsActionSheet(mind),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  height: 100,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MindCreatorBar(
                    focusNode: _mindCreatorFocusNode,
                    textEditingController: _createMarkEditingController,
                    onCreate: (CreateMindData data) {
                      setState(() {
                        _createMarkEditingController.text = '';
                      });
                      BlocUtils.sendTo<MindBloc>(
                        context: context,
                        event: MindCreate(
                          dayIndex: widget.dayIndex,
                          note: data.text,
                          emoji: data.emoji,
                        ),
                      );
                      setState(() {
                        _hideKeyboard();
                      });
                    },
                    suggestionMinds: _hasFocus ? _mindSuggestions?.values ?? [] : [],
                    selectedEmoji: _selectedEmoji,
                    onSelectSuggestionEmoji: (String suggestionEmoji) {
                      setState(() {
                        _selectedEmoji = suggestionEmoji;
                      });
                    },
                    onSearchEmoji: () {
                      _showEmojiPickerScreen(
                        onSelect: (String emoji) {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        },
                      );
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

  void _changeContentVisibility() {
    HapticFeedback.mediumImpact();
    BlocUtils.sendTo<SettingsBloc>(
      context: context,
      event: SettingsChangeMindContentVisibility(isVisible: !_isMindContentVisible),
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showEmojiPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }

  void _showMarkOptionsActionSheet(Mind item) async {
    final result = await showModalActionSheet(
      context: context,
      actions: [
        const SheetAction(
          icon: Icons.edit,
          label: 'Edit emoji',
          key: 'edit_emoji_key',
        ),
        const SheetAction(
          icon: Icons.edit,
          label: 'Edit note',
          key: 'edit_note_key',
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
      BlocUtils.sendTo<MindBloc>(
        context: mountedContext,
        event: MindDelete(uuid: item.id),
      );
    } else if (result == 'edit_note_key') {
      final newNote = await showEditMindAlert(mind: item);
      if (newNote != null) {
        BlocUtils.sendTo<MindBloc>(
          context: mountedContext,
          event: MindEditNote(
            uuid: item.id,
            newNote: newNote,
          ),
        );
      }
    } else if (result == 'edit_emoji_key') {
      _showEmojiPickerScreen(
        onSelect: (String emoji) {
          BlocUtils.sendTo<MindBloc>(
            context: mountedContext,
            event: MindEditEmoji(
              uuid: item.id,
              newEmoji: emoji,
            ),
          );
        },
      );
    }
  }

  Future<void> _showDateSwitcher() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [
        MindUtils.getDateFromIndex(this.dayIndex),
      ],
      config: CalendarDatePicker2WithActionButtonsConfig(),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.isEmpty || dates.first == null) {
      return;
    }

    final int dayIndex = MindUtils.getDayIndex(from: dates.first!);
    setState(() {
      this.dayIndex = dayIndex;
    });
  }
}
