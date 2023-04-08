import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:zenmode/blocs/mind_bloc/mind_bloc.dart';
import 'package:zenmode/constants.dart';
import 'package:zenmode/helpers/bloc_utils.dart';
import 'package:zenmode/helpers/extensions/dispose_bag.dart';
import 'package:zenmode/helpers/extensions/state_extensions.dart';
import 'package:zenmode/helpers/mind_utils.dart';
import 'package:zenmode/screens/mark_creator/mark_creator_screen.dart';
import 'package:zenmode/screens/mark_picker/mark_picker_screen.dart';
import 'package:zenmode/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:zenmode/screens/mind_collection/widgets/my_table.dart';
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
  final FocusNode _createMarkFocusNode = FocusNode();
  String _selectedEmoji = Emoji.all().first.char;
  MindSuggestions? _mindSuggestions;
  bool _createMindBottomBarIsVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // NOTE: Слежение за полем ввода в создании нового майнда при изменении его значения.
      _createMarkEditingController.addListener(() {
        BlocUtils.sendToBloc<MindBloc>(
          context: context,
          event: MindChangeCreateText(text: _createMarkEditingController.text),
        );
      });
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
      } else if (state is MindError) {
        // _showError(text: state.text);
      } else if (state is MindSearching) {
        // setState(() => _searchingMindState = state);
      } else if (state is MindSuggestions) {
        setState(() {
          _mindSuggestions = state;
        });
      }
    }).disposed(by: this);
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormatters.fullDateFormat.format(MindUtils.getDateFromIndex(widget.dayIndex))),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: !_createMindBottomBarIsVisible
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _createMindBottomBarIsVisible = true;
                    _createMarkFocusNode.requestFocus();
                  });
                },
                child: const Icon(
                  Icons.emoji_emotions,
                  size: 40.0,
                ),
              )
            : null,
        body: Stack(
          children: [
            GestureDetector(
              onPanDown: (details) {
                if (_createMarkFocusNode.hasFocus) {
                  setState(() {
                    _createMindBottomBarIsVisible = false;
                    _hideKeyboard();
                  });
                }
              },
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                color: Colors.white,
                child: MyTable(
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
                        .toList()),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: _createMindBottomBarIsVisible,
                  child: Consumer<ScreenHeight>(builder: (context, res, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MindCreatorBar(
                          focusNode: _createMarkFocusNode,
                          textEditingController: _createMarkEditingController,
                          onCreate: (CreateMindData data) {
                            setState(() {
                              _mindSuggestions = null;
                              _createMarkEditingController.text = '';
                            });
                            BlocUtils.sendToBloc<MindBloc>(
                              context: context,
                              event: MindCreate(
                                dayIndex: widget.dayIndex,
                                note: data.text,
                                emoji: data.emoji,
                              ),
                            );
                            _hideKeyboard();
                            _createMindBottomBarIsVisible = false;
                          },
                          suggestionMinds: _mindSuggestions?.values ?? [],
                          selectedEmoji: _selectedEmoji,
                          onSelectSuggestionEmoji: (String suggestionEmoji) {
                            setState(() => _selectedEmoji = suggestionEmoji);
                          },
                          onSearchEmoji: () {
                            _showMarkPickerScreen(
                              onSelect: (String emoji) => setState(() => _selectedEmoji = emoji),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: res.keyboardHeight),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

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
      BlocUtils.sendToBloc<MindBloc>(
        context: mountedContext,
        event: MindDelete(uuid: item.id),
      );
    }
  }
}
