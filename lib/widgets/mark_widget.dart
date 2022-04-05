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
    required this.isHighlighted,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: GrayedOut(
          Text(
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

  GrayedOut(this.child, {this.grayedOut = true});

  @override
  Widget build(BuildContext context) {
    return grayedOut ? Opacity(opacity: 0.5, child: child) : child;
  }
}
