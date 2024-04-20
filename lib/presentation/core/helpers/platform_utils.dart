import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keklist/domain/constants.dart';

class DeviceUtils {
  static SupportedPlatform? safeGetPlatform() {
    if (kIsWeb) {
      return SupportedPlatform.web;
    } else if (Platform.isIOS) {
      return SupportedPlatform.iOS;
    } else if (Platform.isAndroid) {
      return SupportedPlatform.android;
    } else {
      return null;
    }
  }

  static bool isPhone(BuildContext context) => MediaQuery.of(context).size.shortestSide < 550;
}
