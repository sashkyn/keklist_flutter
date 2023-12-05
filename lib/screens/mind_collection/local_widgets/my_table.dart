import 'package:flutter/widgets.dart';
import 'package:keklist/constants.dart';

class MyTable extends StatelessWidget {
  const MyTable({
    super.key,
    required this.widgets,
  });

  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        final int widgetsInRowCount = (constrains.maxWidth / LayoutConstants.mindSide).ceil();
        final int numberOfRows = (widgets.length / widgetsInRowCount).ceil();
        return Table(
          children: List.generate(
            numberOfRows,
            (index) => TableRow(
              children: List.generate(
                widgetsInRowCount,
                (subIndex) {
                  final int itemIndex = index * widgetsInRowCount + subIndex;
                  if (itemIndex < widgets.length) {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: widgets[itemIndex],
                    );
                  } else {
                    return const TableCell(child: SizedBox());
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
