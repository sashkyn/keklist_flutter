import 'package:flutter/widgets.dart';

class MyTable extends StatelessWidget {
  const MyTable({
    Key? key,
    required this.widgets,
    required this.countOfWidgetsInRow,
  }) : super(key: key);

  final List<Widget> widgets;
  final int countOfWidgetsInRow;

  @override
  Widget build(BuildContext context) {
    return Table(
      // border: TableBorder.all(width: 1),
      children: List.generate(
        (widgets.length / countOfWidgetsInRow).ceil(),
        (index) => TableRow(
          children: List.generate(
            countOfWidgetsInRow,
            (subIndex) {
              final int itemIndex = index * countOfWidgetsInRow + subIndex;
              if (itemIndex < widgets.length) {
                return widgets[itemIndex];
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
