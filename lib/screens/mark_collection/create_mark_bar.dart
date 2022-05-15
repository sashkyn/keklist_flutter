import 'package:flutter/material.dart';

class CreateMarkBar extends StatelessWidget {
  final TextEditingController? textController;

  const CreateMarkBar({
    Key? key,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Text(
          'Create new mark with text',
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
