part of 'settings_bloc.dart';

class SettingsState {
  final bool isMindContentVisible;
  final bool needToShowWhatsNewOnStart;

  const SettingsState({
    required this.isMindContentVisible,
    required this.needToShowWhatsNewOnStart,
  });
}
