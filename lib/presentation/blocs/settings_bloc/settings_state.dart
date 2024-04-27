part of 'settings_bloc.dart';

sealed class SettingsState {}

final class SettingsDataState extends SettingsState {
  final bool isLoggedIn;
  final Iterable<Mind> offlineMinds;
  final KeklistSettings settings;

  SettingsDataState({required this.settings, required this.isLoggedIn, required this.offlineMinds});
}

final class SettingsNeedToShowWhatsNew extends SettingsState {}

final class SettingsLoadingState extends SettingsState {
  final bool isLoading;

  SettingsLoadingState(this.isLoading);
}

final class SettingsOfflineMindsState extends SettingsState {
  final Iterable<Mind> mindCandidates;

  SettingsOfflineMindsState(this.mindCandidates);
}

final class SettingsUploadOfflineMindsErrorState extends SettingsState {}

final class SettingsUploadOfflineMindsCompletedState extends SettingsState {}
