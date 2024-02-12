import 'package:chat_gpt_api/app/chat_gpt.dart';
import 'package:chat_gpt_api/app/model/data_model/chat/chat_completion.dart';
import 'package:chat_gpt_api/app/model/data_model/chat/chat_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/mind_day_collection/widgets/bulleted_list/mind_bullet_list_widget.dart';
import 'package:keklist/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
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
  // TODO: move to bloc + repository
  final ChatGPT chatGpt = ChatGPT.builder(token: dotenv.get('OPEN_AI_TOKEN'));

  final TextEditingController _createMindEditingController = TextEditingController(text: null);
  final FocusNode _mindCreatorFocusNode = FocusNode();
  Mind? _editableMind;
  late final String _selectedEmoji = rootMind.emoji;

  Mind get rootMind => widget.rootMind;
  List<Mind> get allMinds => widget.allMinds;
  final List<String> messages = [];

  List<Mind> get childMinds => MindUtils.findMindsByRootId(
        rootId: rootMind.id,
        allMinds: widget.allMinds,
      ).mySortedBy((mind) => mind.creationDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completeWithSSE(rootMind);
    });
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
                      onOptions: null,
                      children: const [],
                    ),
                  ),
                  if (childMinds.isNotEmpty) ...{
                    const Gap(16.0),
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: 8.0,
                    ),
                    MindBulletListWidget(
                      minds: childMinds,
                      onTap: (Mind mind) => () {},
                      onOptions: (Mind mind) => () {},
                    ),
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: 8.0,
                    ),
                  },
                  const Gap(16.0),
                  if (messages.isEmpty) ...{const CircularProgressIndicator()},
                  if (messages.isNotEmpty) ...{
                    MindBulletListWidget(
                      minds: messages
                          .map(
                            (e) => Mind(
                              creationDate: DateTime.now(),
                              emoji: '👨‍⚕️',
                              note: e,
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
                  }
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
                    onTapEmoji: () {},
                    doneTitle: 'DONE',
                    onTapCancelEdit: () => _resetMindCreator(),
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

  void _hideKeyboard() => FocusScope.of(context).requestFocus(FocusNode());

  Future<void> _completeWithSSE(Mind mind) async {
    final String prompt = _makePromt(mind);
    final ChatCompletion? chatCompletion = await chatGpt.chatCompletion(
      request: ChatRequest(
        model: 'gpt-3.5-turbo-0125',
        maxTokens: 256,
        messages: [
          ChatMessage(
            role: 'system',
            content: prompt,
          ),
        ],
      ),
    );
    final String message =
        chatCompletion?.choices?.map((e) => e.message?.content).join('\n') ?? 'Error to get response, try again later';

    messages.clear();
    setState(() {
      messages.add(message);
    });
  }

  String _makePromt(Mind mind) {
    String prompt = '''
        Its my mind with content - ${mind.note}. I set this emoji for this note - ${mind.emoji}.
        Could you give short comment like a pro psycologist?
        Its important to use language of message content for feedback otherwise I dont know english.
        ''';
    return prompt;
  }
}
