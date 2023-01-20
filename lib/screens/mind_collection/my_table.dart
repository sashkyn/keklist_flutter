import 'package:flutter/widgets.dart';

class MyTable extends StatelessWidget {
  const MyTable({
    Key? key,
    required this.widgets,
    required this.widgetsInRowCount,
  }) : super(key: key);

  final List<Widget> widgets;
  final int widgetsInRowCount;

  @override
  Widget build(BuildContext context) {
    return Table(
      // border: TableBorder.all(width: 1),
      children: List.generate(
        (widgets.length / widgetsInRowCount).ceil(),
        (index) => TableRow(
          children: List.generate(
            widgetsInRowCount,
            (subIndex) {
              final int itemIndex = index * widgetsInRowCount + subIndex;
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
