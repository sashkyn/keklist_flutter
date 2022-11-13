import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

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

  // TODO: вернуть использование шрифта noto colored
  /// https://github.com/material-foundation/google-fonts-flutter/issues?q=is%3Aissue+is%3Aopen+noto
  /// Мониторить эту issue

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
              style: TextStyle(fontSize: fontSize), //GoogleFonts.notoEmoji(fontSize: fontSize),
            )),
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
