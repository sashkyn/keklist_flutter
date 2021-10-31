import 'package:flutter/material.dart';

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