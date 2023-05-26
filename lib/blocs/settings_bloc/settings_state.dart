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

  // @override
  // List<Object?> get props => [isMindContentVisible, isOfflineMode];

  SettingsDataState({
    required this.isMindContentVisible,
    required this.isOfflineMode,
  });

  SettingsDataState copyWith({
    bool? isMindContentVisible,
    bool? isOfflineMode,
  }) {
    return SettingsDataState(
      isMindContentVisible: isMindContentVisible ?? this.isMindContentVisible,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
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
