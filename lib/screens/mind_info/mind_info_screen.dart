import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/screens/mind_collection/widgets/mind_creator_bar.dart';
import 'package:rememoji/services/entities/mind.dart';

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

  Mind get rootMind => widget.rootMind;
  List<Mind> get allMinds => widget.allMinds;

  List<Mind> get childMinds => MindUtils.findMindsByRootId(
        rootId: rootMind.id,
        allMinds: widget.allMinds,
      );

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
            ..addAll(state.values.mySortedBy((e) => e.creationDate));
        });
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflections'),
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
                          MindMessageWidget(mind: rootMind),
                        ],
                      ),
                      if (childMinds.isNotEmpty) ...{
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'Reflections:',
                          textAlign: TextAlign.center,
                        ),
                        MindMonologListWidget(
                          minds: childMinds,
                          onTap: (Mind mind) => _showMindOptionsActionSheet(mind),
                          onLongPress: (Mind mind) => () {},
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
                    placeholder: 'Reflect about mind...',
                    onDone: (CreateMindData data) {
                      if (_editableMind == null) {
                        sendEventTo<MindBloc>(
                          MindCreate(
                            dayIndex: rootMind.dayIndex,
                            note: data.text,
                            emoji: '✍️',
                            rootId: rootMind.id,
                          ),
                        );
                      } else {
                        final Mind mindForEdit = _editableMind!.copyWith(
                          note: data.text,
                          emoji: '✍️',
                        );
                        sendEventTo<MindBloc>(MindEdit(mind: mindForEdit));
                      }
                      _resetMindCreator();
                    },
                    suggestionMinds: const [],
                    selectedEmoji: '✍️',
                    onTapSuggestionEmoji: (_) {},
                    onTapEmoji: () {},
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
}
