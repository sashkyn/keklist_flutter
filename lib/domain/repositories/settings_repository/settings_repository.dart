import 'dart:async';

import 'package:keklist/domain/repositories/settings_repository/object/settings_object.dart';

abstract class SettingsRepository {
  KeklistSettings get value;
  Stream<KeklistSettings> get stream;
  FutureOr<void> updateSettings(KeklistSettings settings);
  FutureOr<void> updateOpenAIKey(String? openAIKey);
  FutureOr<void> updateDarkMode(bool isDarkMode);
  FutureOr<void> updateOfflineMode(bool isOfflineMode);
  FutureOr<void> updateMindContentVisibility(bool isVisible);
  FutureOr<void> updatePreviousAppVersion(String? previousAppVersion);
}

final class KeklistSettings {
  final bool isMindContentVisible;
  final String? previousAppVersion;
  final bool isOfflineMode;
  final bool isDarkMode;
  final String? openAIKey;

  KeklistSettings({
    required this.isMindContentVisible,
    required this.previousAppVersion,
    required this.isOfflineMode,
    required this.isDarkMode,
    required this.openAIKey,
  });

  SettingsObject toObject() => SettingsObject()
    ..isMindContentVisible = isMindContentVisible
    ..previousAppVersion = previousAppVersion
    ..isOfflineMode = isOfflineMode
    ..isDarkMode = isDarkMode
    ..openAIKey = openAIKey;

  factory KeklistSettings.initial() => KeklistSettings(
        isMindContentVisible: true,
        previousAppVersion: null,
        isOfflineMode: false,
        isDarkMode: true,
        openAIKey: null,
      );
}
