import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MindCreatorSlidingPanelWidget extends StatefulWidget {
  final Widget body;

  const MindCreatorSlidingPanelWidget({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  State<MindCreatorSlidingPanelWidget> createState() => _MindCreatorSlidingPanelWidgetState();
}

class _MindCreatorSlidingPanelWidgetState extends State<MindCreatorSlidingPanelWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      minHeight: 130.0,
      panel: Column(
        children: [
          const SizedBox(height: 12.0),
          const Text(
            'Create a mind for Today',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            controller: _textEditingController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
              hintText: 'Text for a mind...',
            ),
          ),
        ],
      ),
      body: widget.body,
    );
  }
}