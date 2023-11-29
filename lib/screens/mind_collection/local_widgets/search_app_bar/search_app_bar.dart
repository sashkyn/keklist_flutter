part of '../../mind_collection_screen.dart';

class _SearchAppBar extends StatelessWidget {
  final TextEditingController searchTextController;
  final VoidCallback onSearchAddEmotion;
  final VoidCallback onSearchCancel;

  const _SearchAppBar({
    required this.searchTextController,
    required this.onSearchAddEmotion,
    required this.onSearchCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: _SearchAppBarTextField(
        textController: searchTextController,
        onAddEmotion: onSearchAddEmotion,
        onCancel: onSearchCancel,
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _SearchAppBarTextField extends StatelessWidget {
  final VoidCallback onAddEmotion;
  final VoidCallback onCancel;
  final TextEditingController textController;

  const _SearchAppBarTextField({
    required this.textController,
    required this.onAddEmotion,
    required this.onCancel,
  });

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