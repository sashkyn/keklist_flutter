import 'package:hive_flutter/hive_flutter.dart';

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

  SettingsObject();

  factory SettingsObject.initial() => SettingsObject()
    ..isMindContentVisible = true
    ..previousAppVersion = null
    ..isOfflineMode = false
    ..isDarkMode = true;
}
