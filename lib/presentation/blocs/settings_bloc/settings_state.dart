part of 'settings_bloc.dart';

abstract class SettingsState {}

final class SettingsDataState extends SettingsState {
  final KeklistSettings settings;

  SettingsDataState({required this.settings});
}

final class SettingsNeedToShowWhatsNew extends SettingsState {}

final class SettingsAuthState extends SettingsState {
  final bool needToShowAuth;

  SettingsAuthState(this.needToShowAuth);

  // @override
  // List<Object?> get props => [needToShowAuth];
}
