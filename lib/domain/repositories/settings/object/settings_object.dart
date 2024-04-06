import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';

part 'settings_object.g.dart';

@HiveType(typeId: 0)
final class SettingsObject extends HiveObject {
  @HiveField(0, defaultValue: true)
  late bool isMindContentVisible;

  @HiveField(1, defaultValue: null)
  late String? previousAppVersion;

  @HiveField(2, defaultValue: false)
  late bool isOfflineMode;

  @HiveField(3, defaultValue: true)
  late bool isDarkMode;

  @HiveField(4, defaultValue: null)
  late String? openAIKey = '';

  SettingsObject();

  KeklistSettings toSettings() => KeklistSettings(
        isMindContentVisible: isMindContentVisible,
        previousAppVersion: previousAppVersion,
        isOfflineMode: isOfflineMode,
        openAIKey: openAIKey,
        isDarkMode: isDarkMode,
      );
}
