import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MindSize {
  small,
  medium,
  large,
}

class MindWidget extends StatelessWidget {
  final String item;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double fontSize;

  const MindWidget({
    Key? key,
    required this.item,
    this.isHighlighted = true,
    this.onTap,
    this.onLongPress,
    this.fontSize = 50,
  }) : super(key: key);

  factory MindWidget.sized({
    required String item,
    required MindSize markSize,
    bool isHighlighted = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    switch (markSize) {
      case MindSize.small:
        return MindWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 32,
        );
      case MindSize.medium:
        return MindWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 40,
        );
      case MindSize.large:
        return MindWidget(
          item: item,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongPress,
          fontSize: 50,
        );
    }
  }

  // TODO: вернуть использование шрифта noto colored
  // https://github.com/material-foundation/google-fonts-flutter/issues/267

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Center(
        child: GrayedOut(
          grayedOut: !isHighlighted,
          child: Text(
            item,
            style: GoogleFonts.notoEmoji(fontSize: fontSize),
          ),
        ),
      ),
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
