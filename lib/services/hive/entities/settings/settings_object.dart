import 'package:hive_flutter/hive_flutter.dart';

part 'settings_object.g.dart';

@HiveType(typeId: 0)
class SettingsObject extends HiveObject {
  @HiveField(0, defaultValue: false)
  late bool isMindContentVisible;

  @HiveField(1, defaultValue: null)
  late String? previousAppVersion;

  @HiveField(2, defaultValue: false)
  late bool isOfflineMode;

  SettingsObject();

  factory SettingsObject.initial() => SettingsObject()
      ..isMindContentVisible = false
      ..previousAppVersion = null
      ..isOfflineMode = false;
}
