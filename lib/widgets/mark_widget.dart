import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MarkSize {
  small,
  medium,
  large,
}

class MarkWidget extends StatelessWidget {
  final String item;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double fontSize;

  const MarkWidget({
    Key? key,
    required this.item,
    this.isHighlighted = true,
    this.onTap,
    this.onLongPress,
    this.fontSize = 50,
  }) : super(key: key);

  factory MarkWidget.sized({
    required String item,
    required MarkSize markSize,
    bool isHighlighted = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    switch (markSize) {
      case MarkSize.small:
        return MarkWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 32,
        );
      case MarkSize.medium:
        return MarkWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 40,
        );
      case MarkSize.large:
        return MarkWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 50,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: GrayedOut(
          child: Text(
            item,
            style: GoogleFonts.notoColorEmojiCompat(fontSize: fontSize),
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
