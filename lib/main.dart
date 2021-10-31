import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Emarko',
      home: MarkCollectionWidget(),
    );
  }
}

class MarkCollectionWidget extends StatefulWidget {
  const MarkCollectionWidget({Key? key}) : super(key: key);

  @override
  State<MarkCollectionWidget> createState() => _MarkCollectionWidgetState();
}

class _MarkCollectionWidgetState extends State<MarkCollectionWidget> {
  final Map<int, List<String>> values = {};

  static final DateFormat _formatter = DateFormat('dd.MM.yyyy - EEEE');

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollablePositionedList.builder(
        itemCount: 99999999999,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (BuildContext context, int index) {
          final List<Widget> widgets = values[index]
                  ?.map(
                    (item) => Mark(
                      item: item,
                      onTap: () {
                        _itemScrollController.jumpTo(index: _indexOfDate(DateTime.now()));
                      },
                    ),
                  )
                  .toList() ??
              [];
          widgets.add(Mark(
            item: '📝',
            onTap: () {
              setState(() {
                if (values[index] == null) {
                  values[index] = [];
                }
                final marks = values[index]!;
                marks.add('🥸');
                values[index] = marks;
              });
            },
          ));

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                _formatter.format(_dateFromInt(index)),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              GridView.count(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 5,
                children: widgets,
              ),
            ],
          );
        },
      ),
    );
  }

  DateTime _dateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(1000 * 1000 * 60 * 60 * 24 * index);

  int _indexOfDate(DateTime date) => (date.microsecondsSinceEpoch / (1000 * 1000 * 60 * 60 * 24)).round();
}

class Mark extends StatelessWidget {
  final String item;
  final VoidCallback? onTap;

  const Mark({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Text(
          item,
          style: const TextStyle(fontSize: 50),
        ),
      ),
      onTap: onTap,
    );
  }
}
