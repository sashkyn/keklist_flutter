part of 'settings_bloc.dart';

abstract class SettingsState {}

class SettingsDataState extends SettingsState {
  final bool isMindContentVisible;
  final bool isOfflineMode;
  final Iterable<Mind> cachedMindsToUpload;

  SettingsDataState({
    required this.isMindContentVisible,
    required this.isOfflineMode,
    required this.cachedMindsToUpload,
  });

  SettingsDataState copyWith({
    bool? isMindContentVisible,
    bool? needToShowWhatsNewOnStart,
    bool? isOfflineMode,
    Iterable<Mind>? cachedMindsToUpload,
  }) {
    return SettingsDataState(
      isMindContentVisible: isMindContentVisible ?? this.isMindContentVisible,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      cachedMindsToUpload: cachedMindsToUpload ?? this.cachedMindsToUpload,
    );
  }
}

class SettingsWhatsNewState extends SettingsState with EquatableMixin {
  final bool needToShowWhatsNewOnStart;

  SettingsWhatsNewState(this.needToShowWhatsNewOnStart);
  
  @override
  List<Object?> get props => [needToShowWhatsNewOnStart];
}

class SettingsAuthState extends SettingsState with EquatableMixin {
  final bool needToShowAuth;

  SettingsAuthState(this.needToShowAuth);
  
  @override
  List<Object?> get props => [needToShowAuth];

  @override
  bool? get stringify => true;
}