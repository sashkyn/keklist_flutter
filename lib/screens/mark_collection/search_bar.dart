import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback onCancel;
  final TextEditingController textController;

  const SearchBar({
    Key? key,
    required this.textController,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: TextField(
        controller: textController,
        autofocus: true,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: onCancel,
      ),
    );
  }
}
