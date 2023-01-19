import 'package:flutter/material.dart';

extension MountedContext on State {

  BuildContext? get mountedContext {
    if (!mounted) {
      return null;
    }
    return context;
  }
}