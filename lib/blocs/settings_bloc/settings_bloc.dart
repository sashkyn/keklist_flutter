import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rememoji/services/main_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MainService mainService;

  SettingsBloc({required this.mainService})
      : super(
          const SettingsState(
            isMindContentVisible: false,
            needToShowWhatsNewOnStart: false,
            isOfflineMode: false,
          ),
        ) {
    on<SettingsExportAllMindsToCSV>(_shareCSVFileWithMinds);
    on<SettingsChangeMindContentVisibility>(_changeMindContentVisibility);
    on<SettingsChangeOfflineMode>(_changeOfflineMode);
    on<SettingsWhatsNewShown>(_disableShowingWhatsNewUntillNewVersion);
    on<SettingsGet>(_getSettings);
  }

  FutureOr<void> _shareCSVFileWithMinds(event, emit) async {
    // Получение minds.
    final Iterable<Mind> minds = await mainService.getMindList();
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = minds.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter().convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File csvFile = File('${temporaryDirectory.path}/user_data.csv'); // TODO: добавить дату в название файла.
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }

  FutureOr<void> _getSettings(SettingsGet event, Emitter<SettingsState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isMindContentVisible = prefs.getBool(_SettingsSharedKeys.mindContentVisible) ?? false;
    final bool isOfflineMode = prefs.getBool(_SettingsSharedKeys.offlineMode) ?? false;

    final String? previousAppVersion = prefs.getString(_SettingsSharedKeys.previousAppVersion);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    final bool needToShowWhatsNewOnStart = previousAppVersion != appVersion;

    emit(
      SettingsState(
          isMindContentVisible: isMindContentVisible,
          needToShowWhatsNewOnStart: needToShowWhatsNewOnStart,
          isOfflineMode: isOfflineMode),
    );
  }

  FutureOr<void> _disableShowingWhatsNewUntillNewVersion(
    SettingsWhatsNewShown event,
    Emitter<SettingsState> emit,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    await prefs.setString(_SettingsSharedKeys.previousAppVersion, appVersion);
  }

  FutureOr<void> _changeMindContentVisibility(
    SettingsChangeMindContentVisibility event,
    Emitter<SettingsState> emit,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_SettingsSharedKeys.mindContentVisible, event.isVisible);
    emit(state.copyWith(isMindContentVisible: event.isVisible));
  }

  FutureOr<void> _changeOfflineMode(SettingsChangeOfflineMode event, Emitter<SettingsState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_SettingsSharedKeys.offlineMode, event.isOfflineMode);
    emit(state.copyWith(isOfflineMode: event.isOfflineMode));
  }
}

class _SettingsSharedKeys {
  static const String mindContentVisible = 'settings_mind_content_visible';
  static const String offlineMode = 'settings_mind_offline_mode';
  static const String previousAppVersion = 'settings_previous_app_version';
}
