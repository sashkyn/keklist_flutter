import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/iconed_list/mind_iconed_list_widget.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/helpers/extensions/state_extensions.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/screens/mind_picker/mind_picker_screen.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:rememoji/widgets/bool_widget.dart';
import 'package:rememoji/services/entities/mind.dart';

// TODO: Календарь вашей жизни
// TODO: Перетащить стейт в бар

class MindDayCollectionScreen extends StatefulWidget {
  final int initialDayIndex;
  final Iterable<Mind> allMinds;

  const MindDayCollectionScreen({
    super.key,
    required this.allMinds,
    required this.initialDayIndex,
  });

  @override
  // ignore: no_logic_in_create_state
  State<MindDayCollectionScreen> createState() => _MindDayCollectionScreenState(
        dayIndex: initialDayIndex,
        allMinds: allMinds.mySortedBy((e) => e.sortIndex).toList(),
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
      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMindEditingController.addListener(() {
        BlocUtils.sendEventTo<MindBloc>(
          context: context,
          event: MindChangeCreateText(text: _createMindEditingController.text),
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

    BlocUtils.sendEventTo<SettingsBloc>(
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
                _hideKeyboard();
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
                        onTap: (Mind mind) => _showMindOptionsActionSheet(mind),
                      ),
                      falseChild: MindIconedListWidget(
                        minds: dayMinds,
                        onTap: (Mind mind) => showOkAlertDialog(
                          title: mind.emoji,
                          message: mind.note,
                          context: context,
                        ),
                        onLongTap: (Mind mind) => _showMindOptionsActionSheet(mind),
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
                  onLongTap: (Mind mind) => _showMindOptionsActionSheet(mind),
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
                    editableMind: _editableMind,
                    focusNode: _mindCreatorFocusNode,
                    textEditingController: _createMindEditingController,
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        BlocUtils.sendEventTo<MindBloc>(
                          context: context,
                          event: MindCreate(
                            dayIndex: dayIndex,
                            note: data.text,
                            emoji: data.emoji,
                          ),
                        );
                      } else {
                        final Mind mindForEdit = _editableMind!.copyWith(
                          note: data.text,
                          emoji: data.emoji,
                        );
                        BlocUtils.sendEventTo<MindBloc>(
                          context: context,
                          event: MindEdit(mind: mindForEdit),
                        );
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

  void _resetMindCreator() {
    setState(() {
      _editableMind = null;
      _createMindEditingController.text = '';
      _hideKeyboard();
    });
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _changeContentVisibility() {
    HapticFeedback.mediumImpact();
    BlocUtils.sendEventTo<SettingsBloc>(
      context: context,
      event: SettingsChangeMindContentVisibility(isVisible: !_isMindContentVisible),
    );
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

  void _showMindOptionsActionSheet(Mind mind) async {
    final String? result = await showModalActionSheet(
      context: context,
      actions: [
        const SheetAction(
          icon: Icons.edit,
          label: 'Edit',
          key: 'edit_key',
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
      BlocUtils.sendEventTo<MindBloc>(
        context: mountedContext,
        event: MindDelete(uuid: mind.id),
      );
    } else if (result == 'edit_key') {
      setState(() {
        _editableMind = mind;
        _selectedEmoji = mind.emoji;
      });
      _createMindEditingController.text = mind.note;
      _mindCreatorFocusNode.requestFocus();
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
