part of 'settings_bloc.dart';

// Слишком много завязано на SettingsState

abstract class SettingsState {
  // @override
  // List<Object?> get props => [];

  // @override
  // bool? get stringify => true;
}

class SettingsDataState extends SettingsState {
  final bool isMindContentVisible;
  final bool isOfflineMode;
  final bool isDarkMode;

  // @override
  // List<Object?> get props => [isMindContentVisible, isOfflineMode];

  SettingsDataState({
    required this.isMindContentVisible,
    required this.isOfflineMode,
    required this.isDarkMode,
  });

  SettingsDataState copyWith({
    bool? isMindContentVisible,
    bool? isOfflineMode,
    bool? isDarkMode,
  }) {
    return SettingsDataState(
      isMindContentVisible: isMindContentVisible ?? this.isMindContentVisible,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNeedToShowWhatsNew extends SettingsState { }

class SettingsAuthState extends SettingsState {
  final bool needToShowAuth;

  SettingsAuthState(this.needToShowAuth);

  // @override
  // List<Object?> get props => [needToShowAuth];
}
