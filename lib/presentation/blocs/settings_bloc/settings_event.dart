part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsGet extends SettingsEvent {}

final class SettingsExportAllMindsToCSV extends SettingsEvent {}

final class SettingsChangeMindContentVisibility extends SettingsEvent {
  final bool isVisible;

  const SettingsChangeMindContentVisibility({required this.isVisible});
}

final class SettingsChangeOfflineMode extends SettingsEvent {
  final bool isOfflineMode;

  const SettingsChangeOfflineMode({required this.isOfflineMode});
}

final class SettingsWhatsNewShown extends SettingsEvent {}

final class SettingsUploadMindsFromCacheToServer extends SettingsEvent {}

final class SettingGetWhatsNew extends SettingsEvent {}

final class SettingsChangeIsDarkMode extends SettingsEvent {
  final bool isDarkMode;

  const SettingsChangeIsDarkMode({required this.isDarkMode});
}

final class SettingsChangeOpenAIKey extends SettingsEvent {
  final String openAIToken;

  const SettingsChangeOpenAIKey({required this.openAIToken});
}

final class SettingsLogout extends SettingsEvent {}

final class SettingsGetMindCandidatesToUpload extends SettingsEvent {}

final class SettingsUploadMindCandidates extends SettingsEvent {}

final class SettingsUpdateShouldShowTitlesMode extends SettingsEvent {
  final bool value;

  const SettingsUpdateShouldShowTitlesMode({required this.value});
}

final class SettingsGetAuthState extends SettingsEvent {}