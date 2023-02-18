import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor swatch = MaterialColor(
    0xff000000, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xff333333), //10%
      100: Color(0xff4d4d4d), //20%
      200: Color(0xff666666), //30%
      300: Color(0xff808080), //40%
      400: Color(0xff999999), //50%
      500: Color(0xffb3b3b3), //60%
      600: Color(0xffcccccc), //70%
      700: Color(0xffe6e6e6), //80%
      800: Color(0xffffffff), //90%
      900: Color(0xff000000), //100%
    },
  );
}

class LayoutConstants {
  static double mindSide = 100.0;
}

class ZenConstants {
  static String demoAccountEmail = '***REMOVED***';
  static String termsOfUseURL = 'https://sashkyn.notion.site/Zenmode-Terms-of-Use-df179704b2d149b8a5a915296f5cb78f';

  static List<String> demoModeEmodjiList = [
    '🤔',
    '🚿',
    '💪',
    '💩',
    '☕',
    '💦',
    '👱‍♀️',
    '🇬🇧',
    '🚀',
    '🍚',
    '🍳',
    '🚗',
    '👷🏿',
    '🤙',
    '🧘',
    '🙂',
    '🍵',
    '🥱',
    '🎮',
    '🎬',
    '💻',
    '😡',
    '🥳',
    '🥗',
    '🍝',
    '🍜',
    '🥟',
    '🚶',
    '💡',
    '☺️',
    '🍕',
    '💸',
    '🧟‍♂️',
    '🍣',
    '🥙',
    '🍔',
    '🍑',
    '🥞',
    '👩🏻',
    '😴',
    '🧹',
    '🍫',
    '❌',
    '🤒',
    '🥣',
    '🥔',
    '⚽',
    '🦷',
    '🎁',
    '🎾',
    '🙃',
    '🦈',
    '📚',
    '🇷🇺',
    '🇺🇦',
    '🇷🇸',
    '🍏',
    '😂',
    '🥤',
    '🏃',
    '🛍️',
    '🏂',
    '👧🏻',
    '💊',
    '🍌',
    '🦄',
    '👩',
    '🛬',
    '🛫',
    '💇',
    '🥛',
    '💧',
    '📱',
    '🍐',
    '🥫',
    '🕶️',
    '🥚',
    '🧼',
    '🎧',
    '💵',
    '🍰',
    '👕',
    '😀',
    '🍊',
    '📰',
    '🥲',
    '🥶',
    '🤕',
    '🥪',
    '🍗',
    '📞',
    '🍺',
    '🎄',
    '🌞',
    '😔',
    '😌',
    '💨',
    '🥩',
    '😒',
    '😫',
    '🏨',
    '🚖',
    '🗞️',
    '🏠',
    '🗣️',
    '🚌',
    '🤯',
    '🏋',
    '🚇',
    '🏡',
    '🪒',
    '👨‍🍳',
    '😥',
    '🛒',
    '👀',
    '👨🏻‍🦲',
    '🎥',
    '🤢',
    '🚊',
    '👮',
    '🎵',
    '🎂',
    '😕',
    '🚴',
    '🤧',
    '👁️',
    '🕺',
    '🧀',
    '🏥',
    '🥰',
    '🤣',
    '🌭',
    '👨🏻‍💻',
    '🧘‍♂️',
    '🛁',
    '🧳',
    '👩‍👦',
    '📜',
    '🥐',
    '🍟',
    '🧽',
    '💬',
    '🍷',
    '📲',
    '🍲',
    '🖥️',
    '🤨',
    '💋',
    '🧁',
  ];
}
