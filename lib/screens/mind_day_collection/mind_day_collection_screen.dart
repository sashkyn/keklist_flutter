import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shake/shake.dart';
import 'package:zenmode/blocs/mind_bloc/mind_bloc.dart';
import 'package:zenmode/blocs/settings_bloc/settings_bloc.dart';
import 'package:zenmode/constants.dart';
import 'package:zenmode/helpers/bloc_utils.dart';
import 'package:zenmode/helpers/extensions/dispose_bag.dart';
import 'package:zenmode/helpers/extensions/state_extensions.dart';
import 'package:zenmode/helpers/mind_utils.dart';
import 'package:zenmode/screens/mark_creator/mark_creator_screen.dart';
import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:zenmode/screens/mind_collection/widgets/my_table.dart';
import 'package:zenmode/widgets/bool_widget.dart';
import 'package:zenmode/screens/mind_day_collection/widgets/mind_message_widget.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/typealiases.dart';
import 'package:zenmode/widgets/mind_widget.dart';

class MindDayCollectionScreen extends StatefulWidget {
  final int dayIndex;
  final List<Mind> minds;

  const MindDayCollectionScreen({
    super.key,
    required this.minds,
    required this.dayIndex,
  });

  @override
  State<MindDayCollectionScreen> createState() => _MindDayCollectionScreenState();
}

class _MindDayCollectionScreenState extends State<MindDayCollectionScreen> with DisposeBag {
  // NOTE: Состояние CreateMarkBar с вводом текста.
  final TextEditingController _createMarkEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();

  String _selectedEmoji = Emoji.all().first.char;
  MindSuggestions? _mindSuggestions;
  bool isMindContentVisible = false;

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

      // NOTE: По тряске телефона скрываем/показываем текст эмодзи.
      final ShakeDetector shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () => _changeContentVisibility(),
      );
      shakeDetector.streamSubscription?.disposed(by: this);
    });

    context.read<MindBloc>().stream.listen((state) {
      if (state is MindListState) {
        setState(() {
          final Iterable<Mind> minds = state.values.where(
            (element) => element.dayIndex == widget.dayIndex,
          );
          widget.minds
            ..clear()
            ..addAll(minds);
        });
      } else if (state is MindSuggestions) {
        setState(() {
          _mindSuggestions = state;
        });
      }
    }).disposed(by: this);

    context.read<SettingsBloc>().stream.listen((state) {
      setState(() {
        isMindContentVisible = state.isMindContentVisible;
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
        title: Text(DateFormatters.fullDateFormat.format(MindUtils.getDateFromIndex(widget.dayIndex))),
        actions: [
          IconButton(
            icon: BoolWidget(
              condition: isMindContentVisible,
              trueChild: const Icon(Icons.visibility_off_outlined),
              falseChild: const Icon(Icons.visibility),
            ),
            onPressed: () {
              _changeContentVisibility();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanDown: (details) {
              if (_mindCreatorFocusNode.hasFocus) {
                _hideKeyboard();
              }
            },
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: BoolWidget(
                  condition: isMindContentVisible,
                  falseChild: Column(
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      MyTable(
                        widgets: widget.minds
                            .map(
                              (mind) => MindWidget.sized(
                                item: mind.emoji,
                                size: MindSize.large,
                                onTap: () => showOkAlertDialog(
                                  title: mind.emoji,
                                  message: mind.note,
                                  context: context,
                                ),
                                onLongTap: () {
                                  _showMarkOptionsActionSheet(mind);
                                },
                              ),
                            )
                            .toList(), // TODO: сделать виджет для листа
                      ),
                    ],
                  ),
                  trueChild: Column(
                    children: widget.minds.map((mind) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // border: Border.all(color: Colors.grey),
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
                                  child: MindMessageWidget(mind: mind),
                                ),
                              ),
                            ],
                          );
                        }).toList() +
                        [
                          Column(
                            children: const [
                              SizedBox(height: 160.0),
                            ],
                          ),
                        ], // TODO: сделать виджет для листа
                  ),
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
                      _hideKeyboard();
                    },
                    suggestionMinds: _mindSuggestions?.values ?? [],
                    selectedEmoji: _selectedEmoji,
                    onSelectSuggestionEmoji: (String suggestionEmoji) {
                      setState(() {
                        _selectedEmoji = suggestionEmoji;
                      });
                    },
                    onSearchEmoji: () {
                      _showMarkPickerScreen(
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
    BlocUtils.sendTo<SettingsBloc>(
      context: context,
      event: SettingsChangeMindContentVisibility(isVisible: !isMindContentVisible),
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _hideKeyboard() {
    setState(() {});
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showMarkPickerScreen({required ArgumentCallback<String> onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MarkPickerScreen(onSelect: onSelect),
    );
  }

  void _showMarkOptionsActionSheet(Mind item) async {
    final result = await showModalActionSheet(
      context: context,
      actions: [
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
    }
  }
}