import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:keklist/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/core/screen/kek_screen_state.dart';
import 'package:keklist/screens/actions/action_model.dart';
import 'package:keklist/screens/actions/menu_actions_icon_widget.dart';
import 'package:keklist/screens/mind_chat_discussion/mind_chat_discussion_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/core/helpers/bloc_utils.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/core/helpers/mind_utils.dart';
import 'package:keklist/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
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

final class _MindInfoScreenState extends KekScreenState<MindInfoScreen> {
  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  bool _creatorPanelHasFocus = false;
  Mind? _editableMind;
  late String _selectedEmoji = _rootMind.emoji;

  Mind get _rootMind => widget.rootMind;
  List<Mind> get _allMinds => widget.allMinds;

  List<Mind> get _rootMindChildren => MindUtils.findMindsByRootId(rootId: _rootMind.id, allMinds: widget.allMinds)
      .sortedByFunction((mind) => mind.creationDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _mindCreatorFocusNode.addListener(() {
        if (_creatorPanelHasFocus == _mindCreatorFocusNode.hasFocus) {
          return;
        }
        setState(() {
          _creatorPanelHasFocus = _mindCreatorFocusNode.hasFocus;
        });
      });
    });

    subscribeTo<MindBloc>(onNewState: (state) async {
      if (state is MindList) {
        setState(() {
          _allMinds
            ..clear()
            ..addAll(state.values.sortedByCreationDate());
        });
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind'),
        actions: [
          MenuActionsIconWidget(
            menuActions: [
              ActionModel.chatWithAI(),
              ActionModel.photosPerDay(),
            ],
            action: ActionModel.extraActionsMenu(),
            onMenuAction: (action) {
              switch (action) {
                case ChatWithAIActionModel _:
                  _showMessageScreen(mind: _rootMind);
                  break;
                case PhotosPerDayActionModel _:
                  break;
                default:
                  break;
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 150.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MindMessageWidget(
                      mind: _rootMind,
                      children: _rootMindChildren,
                      onOptions: (Mind mind) {
                        _showMindOptionsActionSheet(mind);
                      },
                    ),
                  ),
                ],
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
                  height: 60,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MindCreatorBottomBar(
                    editableMind: _editableMind,
                    focusNode: _mindCreatorFocusNode,
                    textEditingController: _createMindEditingController,
                    placeholder: 'Comment mind...',
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        sendEventTo<MindBloc>(
                          MindCreate(
                            dayIndex: _rootMind.dayIndex,
                            note: data.text,
                            emoji: _selectedEmoji,
                            rootId: _rootMind.id,
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
                      _showEmojiPickerScreen(
                        onSelect: (String emoji) {
                          setState(() => _selectedEmoji = emoji);
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

  void _showMessageScreen({required Mind mind}) async {
    Navigator.of(mountedContext!).push(
      MaterialPageRoute(
        builder: (_) => MindChatDiscussionScreen(
          rootMind: mind,
          allMinds: _allMinds,
        ),
      ),
    );
  }
}
