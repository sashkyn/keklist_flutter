part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsGet extends SettingsEvent {}

class SettingsExportAllMindsToCSV extends SettingsEvent {}

class SettingsChangeMindContentVisibility extends SettingsEvent {
  final bool isVisible;

  const SettingsChangeMindContentVisibility({required this.isVisible});
}

class SettingsChangeOfflineMode extends SettingsEvent {
  final bool isOfflineMode;

  const SettingsChangeOfflineMode({required this.isOfflineMode});
}

class SettingsWhatsNewShown extends SettingsEvent {}

class SettingsUploadMindsFromCacheToServer extends SettingsEvent {}

class SettingsNeedToShowAuth extends SettingsEvent {}

class SettingGetWhatsNew extends SettingsEvent {}

class SettingsChangeIsDarkMode extends SettingsEvent {
  final bool isDarkMode;

  const SettingsChangeIsDarkMode({required this.isDarkMode});
}

class SettingsChangeOpenAIKey extends SettingsEvent {
  final String openAIToken;

  const SettingsChangeOpenAIKey({required this.openAIToken});
}
