import 'package:flutter/material.dart';
import 'package:keklist/screens/mind_collection/local_widgets/mind_rows_widget.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/widgets/bool_widget.dart';
import 'package:keklist/widgets/rounded_container.dart';

// TODO: добавить дату
// TODO: возможность перехода на источник

class InsightsTodayMindsWidget extends StatefulWidget {
  final List<Mind> todayMinds;

  const InsightsTodayMindsWidget({
    super.key,
    required this.todayMinds,
  });

  @override
  State<InsightsTodayMindsWidget> createState() => _InsightsTodayMindsWidgetState();
}

class _InsightsTodayMindsWidgetState extends State<InsightsTodayMindsWidget> {
  @override
  Widget build(BuildContext context) {
    int listLenght = widget.todayMinds.length;
    if (listLenght == 0) {
      return Container();
    }

    return BoolWidget(
      condition: widget.todayMinds.isNotEmpty,
      falseChild: Container(),
      trueChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RoundedContainer(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Today minds',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              MindRowsWidget(
                minds: widget.todayMinds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
