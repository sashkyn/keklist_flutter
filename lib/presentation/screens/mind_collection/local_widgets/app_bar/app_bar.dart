part of '../../mind_collection_screen.dart';

final class _AppBar extends StatelessWidget {
  final bool isUpdating;
  final VoidCallback onSearch;
  final VoidCallback onTitle;
  final VoidCallback onCalendar;
  final VoidCallback onSettings;

  const _AppBar({
    required this.isUpdating,
    required this.onSearch,
    required this.onTitle,
    required this.onCalendar,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: true,
      actions: _makeAppBarActions(),
      title: GestureDetector(
        onTap: onTitle,
        child: Row(
          children: [
            const Text('Your minds'),
            BoolWidget(
                condition: isUpdating,
                trueChild: const Row(
                  children: [
                    SizedBox(width: 4),
                    CircularProgressIndicator.adaptive(),
                  ],
                ),
                falseChild: const SizedBox.shrink())
          ],
        ),
      ),
    );
  }

  List<Widget>? _makeAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: onSettings,
      ),
      IconButton(
        icon: const Icon(Icons.calendar_month),
        onPressed: onCalendar,
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: onSearch,
      ),
    ];
  }
}
