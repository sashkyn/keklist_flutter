import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:hive/hive.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'settings_event.dart';
part 'settings_state.dart';

// TODO: use mind repo here

final class SettingsBloc extends Bloc<SettingsEvent, SettingsState> with DisposeBag {
  final SupabaseClient client;
  final MindService mainService;
  final Box<MindObject> _mindsBox = Hive.box(HiveConstants.mindBoxName);
  final SettingsRepository repository;

  SettingsBloc({
    required this.mainService,
    required this.client,
    required this.repository,
  }) : super(
          SettingsDataState(
            settings: KeklistSettings(
              isMindContentVisible: true,
              previousAppVersion: null,
              isOfflineMode: false,
              isDarkMode: true,
              openAIKey: null,
            ),
          ),
        ) {
    on<SettingsExportAllMindsToCSV>(_shareCSVFileWithMinds);
    on<SettingsChangeMindContentVisibility>(_changeMindContentVisibility);
    on<SettingsChangeOfflineMode>(_changeOfflineMode);
    on<SettingsWhatsNewShown>(_disableShowingWhatsNewUntillNewVersion);
    on<SettingsGet>(_getSettings);
    on<SettingsNeedToShowAuth>(_showAuth);
    on<SettingGetWhatsNew>(_sendWhatsNewIfNeeded);
    on<SettingsChangeIsDarkMode>(_changeSettingsDarkMode);
    on<SettingsChangeOpenAIKey>(_changeOpenAIKey);

    repository.stream.listen((settings) => add(SettingsGet())).disposed(by: this);
    client.auth.onAuthStateChange.listen((event) => add(SettingsGet())).disposed(by: this);
  }

  FutureOr<void> _shareCSVFileWithMinds(event, emit) async {
    // Получение minds.
    final Iterable<Mind> minds = _mindsBox.values.map((mindObject) => mindObject.toMind());
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = minds.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File csvFile = File('${temporaryDirectory.path}/user_data.csv'); // TODO: добавить дату в название файла.
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }

  void _getSettings(SettingsGet event, Emitter<SettingsState> emit) {
    emit(SettingsDataState(settings: repository.value));

    // Cбор и отправка стейта показа Auth.
    final bool needToShowAuth = !repository.value.isOfflineMode && client.auth.currentUser == null;
    emit(SettingsAuthState(needToShowAuth));
  }

  FutureOr<void> _disableShowingWhatsNewUntillNewVersion(
    SettingsWhatsNewShown event,
    Emitter<SettingsState> emit,
  ) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';

    await repository.updatePreviousAppVersion(appVersion);
  }

  FutureOr<void> _changeMindContentVisibility(
    SettingsChangeMindContentVisibility event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.updateMindContentVisibility(event.isVisible);
  }

  FutureOr<void> _changeOfflineMode(
    SettingsChangeOfflineMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.updateOfflineMode(event.isOfflineMode);

    // Cбор и отправка стейта показа Auth.
    final bool needToShowAuth = !repository.value.isOfflineMode && client.auth.currentUser == null;
    emit(SettingsAuthState(needToShowAuth));
  }

  void _showAuth(SettingsNeedToShowAuth event, Emitter<SettingsState> emit) {
    emit(SettingsAuthState(true));
  }

  FutureOr<void> _changeSettingsDarkMode(SettingsChangeIsDarkMode event, Emitter<SettingsState> emit) async {
    await repository.updateDarkMode(event.isDarkMode);
  }

  Future<void> _sendWhatsNewIfNeeded(SettingGetWhatsNew event, Emitter<SettingsState> emit) async {
    // Cбор и отправка стейта Whats new.
    final String? previousAppVersion = repository.value.previousAppVersion;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    final bool needToShowWhatsNewOnStart = previousAppVersion != appVersion;
    if (needToShowWhatsNewOnStart) {
      emit(SettingsNeedToShowWhatsNew());
    }
  }

  FutureOr<void> _changeOpenAIKey(SettingsChangeOpenAIKey event, Emitter<SettingsState> emit) {
    OpenAI.apiKey = event.openAIToken;
    repository.updateOpenAIKey(event.openAIToken);
  }
}
