import 'package:emarko/mark_picker_screen.dart';
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
      appBar: AppBar(title: const Text('Analoji')),
      body: ScrollablePositionedList.builder(
        itemCount: 99999999999,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (BuildContext context, int index) {
          final List<Widget> widgets = values[index]
                  ?.map(
                    (item) => MarkWidget(
                      item: item,
                      onTap: () {
                        _itemScrollController.jumpTo(index: _getDayIndex(DateTime.now()));
                      },
                    ),
                  )
                  .toList() ??
              [];
          widgets.add(MarkWidget(
            item: '📝',
            onTap: () {
              // Navigator.push<void>(
              //   context,
              //   MaterialPageRoute<void>(
              //     builder: (BuildContext context) => const MarkPickerScreen(),
              //   ),
              // );

              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return MarkPickerScreen(
                    onSelect: (creationMark) {
                      setState(
                        () {
                          if (values[index] == null) {
                            values[index] = [];
                          }
                          final marks = values[index]!;
                          marks.add(creationMark.mark);
                          values[index] = marks;
                        },
                      );
                    },
                  );
                },
              );
            },
          ));

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                _formatter.format(_getDateFromInt(index)),
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

  DateTime _getDateFromInt(int index) => DateTime.fromMicrosecondsSinceEpoch(1000 * 1000 * 60 * 60 * 24 * index);

  int _getDayIndex(DateTime date) => (date.microsecondsSinceEpoch / (1000 * 1000 * 60 * 60 * 24)).round();
}

class MarkWidget extends StatelessWidget {
  final String item;
  final VoidCallback? onTap;

  const MarkWidget({
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
          style: const TextStyle(fontSize: 55),
        ),
      ),
      onTap: onTap,
    );
  }
}
