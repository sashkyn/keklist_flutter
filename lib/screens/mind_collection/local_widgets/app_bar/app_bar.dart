part of '../../mind_collection_screen.dart';

class _AppBar extends StatelessWidget {
  final bool isUpdating;
  final VoidCallback onSearch;
  final VoidCallback onTitle;
  final VoidCallback onCalendar;

  const _AppBar({
    required this.isUpdating,
    required this.onSearch,
    required this.onTitle,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: GestureDetector(
          onTap: onTitle,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Updating'),
              SizedBox(width: 4),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      );
    } else {
      return AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: _makeAppBarActions(),
        title: GestureDetector(
          onTap: onTitle,
          child: const Text('Minds'),
        ),
        backgroundColor: Colors.white,
      );
    }
  }

  List<Widget>? _makeAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.calendar_month),
        color: Colors.black,
        onPressed: onCalendar,
      ),
      IconButton(
        icon: const Icon(Icons.search),
        color: Colors.black,
        onPressed: onSearch,
      ),
    ];
  }
}