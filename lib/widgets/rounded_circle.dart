import 'package:flutter/material.dart';

class RoundedCircle extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final double height;

  const RoundedCircle({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Center(child: child),
    );
  }
}
