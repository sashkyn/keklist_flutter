part of 'settings_bloc.dart';

class SettingsState {
  final bool isMindContentVisible;
  final bool needToShowWhatsNewOnStart;
  final bool isOfflineMode;
  final Iterable<Mind> cachedMindsToUpload;

  const SettingsState({
    required this.isMindContentVisible,
    required this.needToShowWhatsNewOnStart,
    required this.isOfflineMode,
    required this.cachedMindsToUpload,
  });

  SettingsState copyWith({
    bool? isMindContentVisible,
    bool? needToShowWhatsNewOnStart,
    bool? isOfflineMode,
    Iterable<Mind>? cachedMindsToUpload,
  }) {
    return SettingsState(
      isMindContentVisible: isMindContentVisible ?? this.isMindContentVisible,
      needToShowWhatsNewOnStart: needToShowWhatsNewOnStart ?? this.needToShowWhatsNewOnStart,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      cachedMindsToUpload: cachedMindsToUpload ?? this.cachedMindsToUpload,
    );
  }
}
