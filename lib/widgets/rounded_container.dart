import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;

  const RoundedContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10.0,
              offset: const Offset(1.0, 1.0),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
