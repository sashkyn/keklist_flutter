import 'package:flutter/widgets.dart';
import 'package:zenmode/constants.dart';

class MyTable extends StatelessWidget {
  const MyTable({
    Key? key,
    required this.widgets,
  }) : super(key: key);

  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        final widgetsInRowCount = (constrains.maxWidth / LayoutConstants.mindSide).ceil();
        return Table(
          children: List.generate(
            (widgets.length / widgetsInRowCount).ceil(),
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
                    return TableCell(
                      child: Container(),
                    );
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
