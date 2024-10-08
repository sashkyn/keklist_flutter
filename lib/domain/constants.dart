import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

final class Themes {
  static final ThemeData light = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.grey,
    ),
    cardTheme: const CardTheme(color: Colors.white),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: ThemeData().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          decorationColor: Colors.black,
        ),
  );

  static final ThemeData dark = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.grey,
    ),
    cardTheme: const CardTheme(color: Colors.black),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: ThemeData().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
        ),
  );
}

class LayoutConstants {
  static double mindSide = 100.0;
}

class DateFormatters {
  static DateFormat fullDateFormat = DateFormat('dd.MM.yyyy - EEEE');
}

class PlatformConstants {
  static String iosGroupId = 'group.kekable';
  static String iosMindDayWidgetName = 'MindDayWidget';
}

class FlutterConstants {
  static ScrollPhysics mobileOverscrollPhysics =
      const BouncingScrollPhysics().applyTo(const AlwaysScrollableScrollPhysics());
}

enum SupportedPlatform { iOS, android, web }

class KeklistConstants {
  static String demoAccountEmail = dotenv.get('DEMO_ACCOUNT_EMAIL');
  static String termsOfUseURL = 'https://sashkyn.notion.site/Zenmode-Terms-of-Use-df179704b2d149b8a5a915296f5cb78f';
  static String whatsNewURL = 'https://sashkyn.notion.site/Rememoji-Mind-Tracker-8548383aede2406bbb8d26c7f58e769c';
  static String feedbackEmail = 'sashkn2@gmail.com';
  static String sourceCodeURL = 'https://github.com/sashkyn/keklist_flutter';
  static String featureSuggestionURL = 'https://insigh.to/b/keklist';

  static List<String> demoModeEmojiList = [
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
