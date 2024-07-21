import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';

final class SensitiveWidget extends StatelessWidget {
  final Widget child;
  final SensitiveMode mode;
  static bool isProtected = true;

  const SensitiveWidget({
    super.key,
    required this.child,
    this.mode = SensitiveMode.blurred,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case SensitiveMode.hidden:
        return Visibility(
          visible: !isProtected,
          child: child,
        );
      case SensitiveMode.blurred:
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          enabled: isProtected,
          child: child,
        );
      case SensitiveMode.blurredAndNonTappable:
        return BoolWidget(
          condition: isProtected,
          trueChild: SensitiveWidget(
            mode: SensitiveMode.blurred,
            child: IgnorePointer(child: child),
          ),
          falseChild: child,
        );
      case SensitiveMode.nonTappable:
        return BoolWidget(
          condition: isProtected,
          trueChild: IgnorePointer(child: child),
          falseChild: child,
        );
    }
  }
}

enum SensitiveMode {
  blurred,
  hidden,
  blurredAndNonTappable,
  nonTappable,
}
