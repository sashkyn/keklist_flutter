import 'package:flutter/cupertino.dart';
import 'package:keklist/core/dispose_bag.dart';

abstract class KekScreenState<W extends StatefulWidget> extends State<W> with DisposeBag {
  
  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }
}