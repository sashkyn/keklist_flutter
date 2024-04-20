import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:keklist/presentation/blocs/message_bloc/message_bloc.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_list_widget.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_widget.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:keklist/domain/services/entities/message.dart';
import 'package:keklist/domain/services/entities/mind.dart';

final class MindChatDiscussionScreen extends StatefulWidget {
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

final class _MindChatDiscussionScreenState extends KekWidgetState<MindChatDiscussionScreen> {
  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  Mind? _editableMind;

  Mind get rootMind => widget.rootMind;
  final List<Message> messages = [];
  bool _isLoading = false;

  late final MessageBloc _bloc = MessageBloc();

  List<Mind> get mindChildren => MindUtils.findMindsByRootId(
        rootId: rootMind.id,
        allMinds: widget.allMinds,
      ).sortedByFunction((mind) => mind.creationDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(MessageGetAll());
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    await _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, MessageState state) {
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
          case MessageError errorState:
            setState(() => _isLoading = false);
            showOkAlertDialog(
              context: context,
              title: 'Error',
              message: errorState.message,
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discussion'),
          actions: [
            IconButton(
              icon: const Icon(Icons.update),
              onPressed: () => _bloc.add(MessageClearChatWithMind(rootMindId: rootMind.id)),
            ),
          ],
        ),
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
                        onRootOptions: null,
                        onChildOptions: null,
                        children: mindChildren,
                      ),
                    ),
                    const Gap(16.0),
                    if (messages.isEmpty && !_isLoading) ...{
                      ElevatedButton(
                        onPressed: () => _bloc.add(
                          MessageStartDiscussion(
                            mind: rootMind,
                            mindChildren: mindChildren,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Start discussion',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    },
                    if (messages.isNotEmpty) ...{
                      MindBulletListWidget(
                        models: messages
                            .map(
                              (message) => MindBulletModel(
                                entityId: message.id,
                                emoji: message.sender == MessageSender.assistant ? '👨‍⚕️' : '💬',
                                text: message.text,
                              ),
                            )
                            .toList(),
                        onTap: (_) {},
                        onLongPress: (_) {},
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
                        _bloc.add(
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
