import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/services/hive/constants.dart';
import 'package:rememoji/services/hive/entities/settings/settings_object.dart';
import 'package:share_plus/share_plus.dart';
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

  final Box<SettingsObject> _settingsBox = Hive.box<SettingsObject>(HiveConstants.settingsBoxName);

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
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);

    final bool isMindContentVisible = settingsObject?.isMindContentVisible ?? false;
    final bool isOfflineMode = settingsObject?.isOfflineMode ?? false;

    final String? previousAppVersion = settingsObject?.previousAppVersion;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    final bool needToShowWhatsNewOnStart = previousAppVersion != appVersion;

    emit(
      SettingsState(
        isMindContentVisible: isMindContentVisible,
        needToShowWhatsNewOnStart: needToShowWhatsNewOnStart,
        isOfflineMode: isOfflineMode,
      ),
    );
  }

  FutureOr<void> _disableShowingWhatsNewUntillNewVersion(
    SettingsWhatsNewShown event,
    Emitter<SettingsState> emit,
  ) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';

    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.previousAppVersion = appVersion;
    settingsObject?.save();
  }

  FutureOr<void> _changeMindContentVisibility(
    SettingsChangeMindContentVisibility event,
    Emitter<SettingsState> emit,
  ) async {
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isMindContentVisible = event.isVisible;
    _settingsBox.put(HiveConstants.settingsGlobalSettingsIndex, settingsObject!);

    emit(state.copyWith(isMindContentVisible: event.isVisible));
  }

  FutureOr<void> _changeOfflineMode(SettingsChangeOfflineMode event, Emitter<SettingsState> emit) async {
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isOfflineMode = event.isOfflineMode;
    settingsObject?.save();
    emit(state.copyWith(isOfflineMode: event.isOfflineMode));
  }
}
