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

class SettingsOfflineUploadCandidates extends SettingsState with EquatableMixin {
  final Iterable<Mind> cachedMindsToUpload;

  SettingsOfflineUploadCandidates(this.cachedMindsToUpload);

  @override
  List<Object?> get props => [cachedMindsToUpload];

  @override
  bool? get stringify => true;
}
