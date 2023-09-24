import 'package:flutter/material.dart';
import 'package:rememoji/widgets/rounded_circle.dart';

class RoundedText extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const RoundedText({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedCircle(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: 1,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
