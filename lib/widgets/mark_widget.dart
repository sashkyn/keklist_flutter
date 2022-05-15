import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkWidget extends StatelessWidget {
  final String item;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MarkWidget({
    Key? key,
    required this.item,
    this.isHighlighted = true,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: GrayedOut(
          child: Text(
            item,
            style: GoogleFonts.notoColorEmojiCompat(fontSize: 50),
          ),
          grayedOut: !isHighlighted,
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class GrayedOut extends StatelessWidget {
  final Widget child;
  final bool grayedOut;

  const GrayedOut({
    Key? key,
    required this.child,
    required this.grayedOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => grayedOut ? Opacity(opacity: 0.25, child: child) : child;
}
