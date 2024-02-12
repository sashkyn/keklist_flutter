import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keklist/constants.dart';

class DeviceUtils {
  static SupportedPlatform safeGetPlatform(BuildContext context) {
    if (kIsWeb) {
      return SupportedPlatform.web;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return SupportedPlatform.iOS;
    } else {
      return SupportedPlatform.android;
    }
  }

  static bool isPhone(BuildContext context) => MediaQuery.of(context).size.shortestSide < 550;
}
