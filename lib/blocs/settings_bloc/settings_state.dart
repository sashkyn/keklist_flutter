part of 'settings_bloc.dart';

abstract class SettingsState {}

class SettingsDataState extends SettingsState {
  final bool isMindContentVisible;
  final bool isOfflineMode;

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

class SettingsAuthState extends SettingsState with EquatableMixin {
  final bool needToShowAuth;

  SettingsAuthState(this.needToShowAuth);

  @override
  List<Object?> get props => [needToShowAuth];

  @override
  bool? get stringify => true;
}
