part of 'settings_bloc.dart';

abstract class SettingsEvent {
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

class SettingsGetUploadCandidates extends SettingsEvent {}
