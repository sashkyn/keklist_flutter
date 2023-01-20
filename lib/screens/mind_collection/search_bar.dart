import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback onAddEmotion;
  final VoidCallback onCancel;
  final TextEditingController textController;

  const SearchBar({
    Key? key,
    required this.textController,
    required this.onAddEmotion,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Flexible(
          flex: 1,
          child: Icon(
            Icons.search,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 10,
          child: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search for your notes',
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.black,
            ),
            onPressed: onAddEmotion,
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.black,
            ),
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }
}
