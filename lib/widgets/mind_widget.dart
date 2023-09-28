import 'package:flutter/material.dart';
import 'package:rememoji/widgets/bool_widget.dart';
import 'package:rememoji/widgets/rounded_circle.dart';

enum MindSize {
  small,
  medium,
  large,
}

class MindWidget extends StatelessWidget {
  final String item;
  final String? badge;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double fontSize;

  const MindWidget({
    Key? key,
    required this.item,
    this.badge,
    this.isHighlighted = true,
    this.onTap,
    this.onLongPress,
    this.fontSize = 50,
  }) : super(key: key);

  factory MindWidget.justEmoji({
    required String emoji,
    double? size,
  }) {
    return MindWidget(
      item: emoji,
      isHighlighted: true,
      onTap: null,
      onLongPress: null,
      fontSize: size ?? 50,
    );
  }

  factory MindWidget.sized({
    required String item,
    required MindSize size,
    required String? badge,
    bool isHighlighted = true,
    VoidCallback? onTap,
    VoidCallback? onLongTap,
  }) {
    switch (size) {
      case MindSize.small:
        return MindWidget(
          item: item,
          badge: badge,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongTap,
          fontSize: 32,
        );
      case MindSize.medium:
        return MindWidget(
          item: item,
          badge: badge,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongTap,
          fontSize: 40,
        );
      case MindSize.large:
        return MindWidget(
          item: item,
          badge: badge,
          isHighlighted: isHighlighted,
          onTap: onTap,
          onLongPress: onLongTap,
          fontSize: 50,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Center(
            child: GrayedOut(
              grayedOut: !isHighlighted,
              child: Text(item,
                  style: TextStyle(
                    // fontFamily: 'NotoColorEmoji',
                    fontSize: fontSize,
                  )),
            ),
          ),
          BoolWidget(
            condition: badge != null,
            trueChild: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: RoundedCircle(
                  height: 16.0,
                  width: 16.0,
                  backgroundColor: Colors.lightGreen,
                  borderColor: Colors.white,
                  borderWidth: 2.0,
                  child: Container(),
                ),
              ),
            ),
            falseChild: Container(),
          )
        ],
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
