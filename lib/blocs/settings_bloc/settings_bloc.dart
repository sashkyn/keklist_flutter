import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/services/hive/constants.dart';
import 'package:rememoji/services/hive/entities/mind/mind_object.dart';
import 'package:rememoji/services/hive/entities/settings/settings_object.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rememoji/services/main_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SupabaseClient client;
  final MainService mainService;
  final Box<MindObject> _mindsBox = Hive.box(HiveConstants.mindBoxName);
  final Box<SettingsObject> _settingsBox = Hive.box(HiveConstants.settingsBoxName);

  late SettingsDataState _lastSettingsState;

  SettingsBloc({
    required this.mainService,
    required this.client,
  }) : super(
          SettingsDataState(
            isMindContentVisible: true,
            isOfflineMode: false,
          ),
        ) {
    _lastSettingsState = state as SettingsDataState;

    on<SettingsExportAllMindsToCSV>(_shareCSVFileWithMinds);
    on<SettingsChangeMindContentVisibility>(_changeMindContentVisibility);
    on<SettingsChangeOfflineMode>(_changeOfflineMode);
    on<SettingsWhatsNewShown>(_disableShowingWhatsNewUntillNewVersion);
    on<SettingsGet>(_getSettings);
    on<SettingsNeedToShowAuth>(_showAuth);
    on<SettingGetWhatsNew>(_sendWhatsNewIfNeeded);
  }

  FutureOr<void> _shareCSVFileWithMinds(event, emit) async {
    // Получение minds.
    final Iterable<Mind> minds = _mindsBox.values.map((mindObject) => mindObject.toMind());
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = minds.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter().convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File csvFile = File('${temporaryDirectory.path}/user_data.csv'); // TODO: добавить дату в название файла.
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }

  void _getSettings(SettingsGet event, Emitter<SettingsState> emit) {
    // Cбор и отправка стейта с настройками.
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    final bool isMindContentVisible = settingsObject?.isMindContentVisible ?? false;
    final bool isOfflineMode = settingsObject?.isOfflineMode ?? false;
    _emitAndSaveDataState(
      emit,
      SettingsDataState(
        isMindContentVisible: isMindContentVisible,
        isOfflineMode: isOfflineMode,
      ),
    );

    // TODO: низя - побочное действие
    // TODO: почитать про взаимодействие с несколькими блоками
    // Cбор и отправка стейта показа Auth.
    final bool needToShowAuth = !isOfflineMode && client.auth.currentUser == null;
    emit(SettingsAuthState(needToShowAuth));
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

    _emitAndSaveDataState(
      emit,
      _lastSettingsState.copyWith(isMindContentVisible: event.isVisible),
    );
  }

  FutureOr<void> _changeOfflineMode(
    SettingsChangeOfflineMode event,
    Emitter<SettingsState> emit,
  ) async {
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isOfflineMode = event.isOfflineMode;
    settingsObject?.save();

    _emitAndSaveDataState(
      emit,
      _lastSettingsState.copyWith(isOfflineMode: event.isOfflineMode),
    );

    // Cбор и отправка стейта показа Auth.
    final bool needToShowAuth = !_lastSettingsState.isOfflineMode && client.auth.currentUser == null;
    emit(SettingsAuthState(needToShowAuth));
  }

  void _showAuth(SettingsNeedToShowAuth event, Emitter<SettingsState> emit) {
    emit(SettingsAuthState(true));
  }

  void _emitAndSaveDataState(Emitter<SettingsState> emit, SettingsDataState state) {
    if (_lastSettingsState == state) {
      return;
    }

    _lastSettingsState = state;
    emit(state);
  }

  Future<void> _sendWhatsNewIfNeeded(SettingGetWhatsNew event, Emitter<SettingsState> emit) async {
    // Cбор и отправка стейта Whats new.
    final SettingsObject? settingsObject = _settingsBox.get(HiveConstants.settingsGlobalSettingsIndex);
    final String? previousAppVersion = settingsObject?.previousAppVersion;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    final bool needToShowWhatsNewOnStart = previousAppVersion != appVersion;
    if (needToShowWhatsNewOnStart) {
      emit(SettingsNeedToShowWhatsNew());
    }
  }
}
