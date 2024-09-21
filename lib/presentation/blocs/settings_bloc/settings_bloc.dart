import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/auth/auth_service.dart';
import 'package:keklist/domain/services/auth/kek_user.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

part 'settings_event.dart';
part 'settings_state.dart';

final class SettingsBloc extends Bloc<SettingsEvent, SettingsState> with DisposeBag {
  final SettingsRepository _repository;
  final MindRepository _mindRepository;
  final MindService _mindService;
  final AuthService _authService;

  SettingsBloc({
    required AuthService authService,
    required SettingsRepository repository,
    required MindRepository mindRepository,
    required MindService mindService,
  })  : _authService = authService,
        _mindService = mindService,
        _repository = repository,
        _mindRepository = mindRepository,
        super(
          SettingsDataState(
            isLoggedIn: authService.currentUser != null,
            offlineMinds: const [],
            settings: KeklistSettings.initial(),
          ),
        ) {
    on<SettingsExportAllMindsToCSV>(_shareCSVFileWithMinds);
    on<SettingsChangeMindContentVisibility>(_changeMindContentVisibility);
    on<SettingsChangeOfflineMode>(_changeOfflineMode);
    on<SettingsWhatsNewShown>(_disableShowingWhatsNewUntillNewVersion);
    on<SettingsGet>(_getSettings);
    on<SettingGetWhatsNew>(_sendWhatsNewIfNeeded);
    on<SettingsChangeIsDarkMode>(_changeSettingsDarkMode);
    on<SettingsChangeOpenAIKey>(_changeOpenAIKey);
    on<SettingsLogout>(_logout);
    on<SettingsGetMindCandidatesToUpload>(_getMindUploadCandidates);
    on<SettingsUploadMindCandidates>(_uploadMindCandidates);
    on<SettingsUpdateShouldShowTitlesMode>(_updateShouldShowTitlesMode);

    _repository.stream.listen((settings) => add(SettingsGet())).disposed(by: this);
    _authService.currentUserStream.listen((_) => add(SettingsGet())).disposed(by: this);
    Rx.combineLatest2(
      _authService.currentUserStream,
      _repository.stream.map((settings) => settings.isOfflineMode),
      (KekUser? currentUser, bool offlineMode) => currentUser != null || !offlineMode,
    ).listen((event) => add(SettingsGet())).disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();
    return super.close();
  }

  FutureOr<void> _shareCSVFileWithMinds(event, emit) async {
    // Получение minds.
    final Iterable<Mind> minds = _mindRepository.values;
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = minds.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final String formattedDateString = DateTime.now().toString().replaceAll('.', '-');
    final File csvFile = File('${temporaryDirectory.path}/keklist_backup_data_$formattedDateString.csv');
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }

  FutureOr _getSettings(SettingsGet event, Emitter<SettingsState> emit) async {
    final Iterable<Mind> offlineMinds = await _mindRepository.obtainNotUploadedToServerMinds();
    emit(
      SettingsDataState(
        offlineMinds: offlineMinds,
        settings: _repository.value,
        isLoggedIn: _authService.currentUser != null,
      ),
    );
  }

  FutureOr<void> _disableShowingWhatsNewUntillNewVersion(
    SettingsWhatsNewShown event,
    Emitter<SettingsState> emit,
  ) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';

    await _repository.updatePreviousAppVersion(appVersion);
  }

  FutureOr<void> _changeMindContentVisibility(
    SettingsChangeMindContentVisibility event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.updateMindContentVisibility(event.isVisible);
  }

  FutureOr<void> _changeOfflineMode(
    SettingsChangeOfflineMode event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.updateOfflineMode(event.isOfflineMode);
  }

  FutureOr<void> _changeSettingsDarkMode(SettingsChangeIsDarkMode event, Emitter<SettingsState> emit) async {
    await _repository.updateDarkMode(event.isDarkMode);
  }

  FutureOr<void> _sendWhatsNewIfNeeded(SettingGetWhatsNew event, Emitter<SettingsState> emit) async {
    // Cбор и отправка стейта Whats new.
    final String? previousAppVersion = _repository.value.previousAppVersion;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    final bool needToShowWhatsNewOnStart = previousAppVersion != appVersion;
    if (needToShowWhatsNewOnStart) {
      emit(SettingsNeedToShowWhatsNew());
    }
  }

  FutureOr<void> _changeOpenAIKey(SettingsChangeOpenAIKey event, Emitter<SettingsState> emit) {
    OpenAI.apiKey = event.openAIToken;
    _repository.updateOpenAIKey(event.openAIToken);
  }

  FutureOr<void> _logout(SettingsLogout event, Emitter<SettingsState> emit) async {
    await _authService.logout();
  }

  FutureOr<void> _getMindUploadCandidates(
    SettingsGetMindCandidatesToUpload event,
    Emitter<SettingsState> emit,
  ) async {
    final Iterable<Mind> uploadCandidates = await _mindRepository.obtainNotUploadedToServerMinds();
    emit(SettingsOfflineMindsState(uploadCandidates));
  }

  Future<void> _uploadMindCandidates(
    SettingsUploadMindCandidates event,
    Emitter<SettingsState> emit,
  ) async {
    final Iterable<Mind> offlineMinds = await _mindRepository.obtainNotUploadedToServerMinds();
    emit(SettingsLoadingState(true));

    final Iterable<Mind> rootOfflineMinds = offlineMinds.where((Mind mind) => mind.rootId == null);
    final Future<void> uploadRootMind = _mindService.addAllMinds(values: rootOfflineMinds);
    final Iterable<Mind> childOfflineMinds = offlineMinds.where((Mind mind) => mind.rootId != null);
    final Future<void> uploadChildMinds = _mindService.addAllMinds(values: childOfflineMinds);

    await uploadRootMind.then((_) async {
      await uploadChildMinds.then((_) async {
        await _mindRepository
            .deleteMindsWhere((Mind mind) => offlineMinds.any((Mind candidate) => candidate.id == mind.id));
        await _mindRepository.updateMinds(
          minds: offlineMinds,
          isUploadedToServer: true,
        );
      });
    }).onError((error, stackTrace) {
      emit(SettingsUploadOfflineMindsErrorState());
    });
    emit(SettingsUploadOfflineMindsCompletedState());
    emit(SettingsLoadingState(false));
  }

  FutureOr<void> _updateShouldShowTitlesMode(
      SettingsUpdateShouldShowTitlesMode event, Emitter<SettingsState> emit) async {
    await _repository.updateShouldShowTitles(event.value);
  }
}
