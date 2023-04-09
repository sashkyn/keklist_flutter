import 'package:flutter/material.dart';

class BoolWidget extends StatelessWidget {
  final bool condition;
  final Widget trueChild;
  final Widget falseChild;

  const BoolWidget({
    Key? key,
    required this.condition,
    required this.trueChild,
    required this.falseChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return trueChild;
    } else {
      return falseChild;
    }
  }
}
