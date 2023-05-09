part of 'settings_bloc.dart';

class SettingsState {
  final bool isMindContentVisible;
  final bool needToShowWhatsNewOnStart;
  final bool isOfflineMode;

  const SettingsState({
    required this.isMindContentVisible,
    required this.needToShowWhatsNewOnStart,
    required this.isOfflineMode,
  });

  SettingsState copyWith({
    bool? isMindContentVisible,
    bool? needToShowWhatsNewOnStart,
    bool? isOfflineMode,
  }) {
    return SettingsState(
      isMindContentVisible: isMindContentVisible ?? this.isMindContentVisible,
      needToShowWhatsNewOnStart: needToShowWhatsNewOnStart ?? this.needToShowWhatsNewOnStart,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}
