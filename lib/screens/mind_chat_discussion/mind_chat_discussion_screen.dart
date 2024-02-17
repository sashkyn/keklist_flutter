import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keklist/blocs/message_bloc/message_bloc.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_list_widget.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/services/entities/message.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:uuid/uuid.dart';

class MindChatDiscussionScreen extends StatefulWidget {
  final Mind rootMind;
  final List<Mind> allMinds;

  const MindChatDiscussionScreen({
    super.key,
    required this.rootMind,
    required this.allMinds,
  });

  @override
  State<MindChatDiscussionScreen> createState() => _MindChatDiscussionScreenState();
}

class _MindChatDiscussionScreenState extends State<MindChatDiscussionScreen> {
  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  Mind? _editableMind;

  Mind get rootMind => widget.rootMind;
  List<Mind> get allMinds => widget.allMinds;
  final List<Message> messages = [];
  bool _isLoading = false;

  List<Mind> get mindChildren => MindUtils.findMindsByRootId(
        rootId: rootMind.id,
        allMinds: widget.allMinds,
      ).mySortedBy((mind) => mind.creationDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendEventTo<MessageBloc>(MessageGetAll());
    });

    subscribeTo<MessageBloc>(
      onNewState: (state) {
        switch (state) {
          case MessageChat chatState:
            setState(() {
              messages.clear();
              final List<Message> chatMessages =
                  chatState.messages.where((element) => element.rootMindId == rootMind.id).toList();
              messages.addAll(chatMessages);
            });
          case MessageLoadingStatus loadingState:
            if (_isLoading == loadingState.isLoading) {
              return;
            }
            setState(() {
              _isLoading = loadingState.isLoading;
            });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 150.0),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MindMessageWidget(
                      mind: rootMind,
                      onOptions: () => sendEventTo<MessageBloc>(MessageClearChatWithMind(rootMindId: rootMind.id)),
                      children: mindChildren,
                    ),
                  ),
                  const Gap(16.0),
                  if (messages.isEmpty) ...{
                    ElevatedButton(
                      onPressed: () => sendEventTo<MessageBloc>(
                        MessageStartDiscussion(
                          mind: rootMind,
                          children: mindChildren,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Start discussion',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  },
                  if (messages.isNotEmpty) ...{
                    MindBulletListWidget(
                      minds: messages
                          .map(
                            (e) => Mind(
                              creationDate: DateTime.now(),
                              emoji: '👨‍⚕️',
                              note: e.text,
                              id: const Uuid().v4(),
                              dayIndex: 0,
                              sortIndex: 0,
                              rootId: null,
                            ),
                          )
                          .toList(),
                      onTap: (_) {},
                      onOptions: (_) {},
                    ),
                  },
                  const Gap(8.0),
                  if (_isLoading) ...{const CircularProgressIndicator()},
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
                    placeholder: 'Send message...',
                    onDone: (CreateMindData data) {
                      sendEventTo<MessageBloc>(
                        MessageSend(
                          message: data.text,
                          rootMindId: rootMind.id,
                        ),
                      );
                      _resetBottomBar();
                    },
                    suggestionMinds: const [],
                    selectedEmoji: null,
                    onTapSuggestionEmoji: (_) {},
                    onTapEmoji: () {},
                    doneTitle: 'SEND',
                    onTapCancelEdit: () => _resetBottomBar(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetBottomBar() {
    setState(() {
      _editableMind = null;
      _createMindEditingController.text = '';
      _hideKeyboard();
    });
  }

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());
}
