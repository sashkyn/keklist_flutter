import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_list_widget.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/extensions/dispose_bag.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:keklist/screens/mind_picker/mind_picker_screen.dart';
import 'package:keklist/services/entities/mind.dart';

final class MindInfoScreen extends StatefulWidget {
  final Mind rootMind;
  final List<Mind> allMinds;

  const MindInfoScreen({
    super.key,
    required this.rootMind,
    required this.allMinds,
  });

  @override
  State<MindInfoScreen> createState() => _MindInfoScreenState();
}

final class _MindInfoScreenState extends State<MindInfoScreen> with DisposeBag {
  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  bool _hasFocus = false;
  Mind? _editableMind;
  late String _selectedEmoji = rootMind.emoji;

  Mind get rootMind => widget.rootMind;
  List<Mind> get allMinds => widget.allMinds;

  List<Mind> get childMinds => MindUtils.findMindsByRootId(
        rootId: rootMind.id,
        allMinds: widget.allMinds,
      ).mySortedBy((mind) => mind.creationDate);

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
    });

    subscribeTo<MindBloc>(onNewState: (state) async {
      if (state is MindList) {
        setState(() {
          allMinds
            ..clear()
            ..addAll(state.values.mySortedBy((mind) => mind.creationDate));
        });
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind'),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) {
              if (_mindCreatorFocusNode.hasFocus) {
                _hideKeyboard();
              }
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MindMessageWidget(
                            mind: rootMind,
                            onOptions: null,
                            children: const [],
                          ),
                        ],
                      ),
                      if (childMinds.isNotEmpty) ...{
                        const Gap(16.0),
                        Container(
                          color: Colors.white,
                          height: 8.0,
                        ),
                        MindBulletListWidget(
                          minds: childMinds,
                          onTap: (Mind mind) => () {},
                          onOptions: (Mind mind) => _showMindOptionsActionSheet(mind),
                        ),
                        Container(
                          color: Colors.white,
                          height: 8.0,
                        ),
                      }
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              // NOTE: Подложка для скрытия текста эмодзи.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  height: 90,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MindCreatorBar(
                    editableMind: _editableMind,
                    focusNode: _mindCreatorFocusNode,
                    textEditingController: _createMindEditingController,
                    placeholder: 'Comment your mind...',
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        sendEventTo<MindBloc>(
                          MindCreate(
                            dayIndex: rootMind.dayIndex,
                            note: data.text,
                            emoji: _selectedEmoji,
                            rootId: rootMind.id,
                          ),
                        );
                      } else {
                        final Mind mindForEdit = _editableMind!.copyWith(
                          note: data.text,
                          emoji: _selectedEmoji,
                        );
                        sendEventTo<MindBloc>(MindEdit(mind: mindForEdit));
                      }
                      _resetMindCreator();
                    },
                    suggestionMinds: const [],
                    selectedEmoji: _selectedEmoji,
                    onTapSuggestionEmoji: (_) {},
                    onTapEmoji: () {
                      _showEmojiPickerScreen(onSelect: (String emoji) {
                        setState(() => _selectedEmoji = emoji);
                      });
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

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
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
      sendEventTo<MindBloc>(MindDelete(uuid: mind.id));
    } else if (result == 'edit_key') {
      setState(() {
        _editableMind = mind;
      });
      _createMindEditingController.text = mind.note;
      _mindCreatorFocusNode.requestFocus();
    }
  }

  void _showEmojiPickerScreen({required Function(String) onSelect}) async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => MindPickerScreen(onSelect: onSelect),
    );
  }
}
