import 'package:flutter/material.dart';
import 'package:keklist/presentation/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/actions/menu_actions_icon_widget.dart';
import 'package:keklist/presentation/screens/mind_chat_discussion/mind_chat_discussion_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:keklist/presentation/screens/mind_picker/mind_picker_screen.dart';
import 'package:keklist/domain/services/entities/mind.dart';

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
            action: ActionModel.extraActions(),
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
                      onOptions: (Mind mind) => _showActions(mind),
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

  void _showActions(Mind mind) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (ActionModel.edit(), () => _showMessageScreen(mind: mind)),
          (
            ActionModel.delete(),
            () {
              setState(() {
                _editableMind = mind;
              });
              _createMindEditingController.text = mind.note;
              _mindCreatorFocusNode.requestFocus();
            }
          ),
        ],
      ),
    );
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