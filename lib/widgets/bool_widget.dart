import 'package:flutter/material.dart';

class BoolWidget extends StatelessWidget {
  final bool condition;
  final Widget trueChild;
  final Widget? falseChild;

  const BoolWidget({
    super.key,
    required this.condition,
    required this.trueChild,
    this.falseChild,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return trueChild;
    } else {
      return falseChild ?? trueChild;
    }
  }
}
