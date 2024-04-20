import 'package:flutter/cupertino.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';

abstract class KekWidgetState<W extends StatefulWidget> extends State<W> with DisposeBag {
  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }
}
