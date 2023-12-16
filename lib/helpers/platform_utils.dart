import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keklist/constants.dart';

class SupportedPlatformUtils {
  static SupportedPlatform getPlatform(BuildContext context) {
    if (kIsWeb) {
      return SupportedPlatform.web;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return SupportedPlatform.iOS;
    } else {
      return SupportedPlatform.android;
    }
  }
}