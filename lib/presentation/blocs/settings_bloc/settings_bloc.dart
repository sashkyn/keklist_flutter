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
import 'package:keklist/presentation/core/widgets/mind_widget.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

part 'settings_event.dart';
part 'settings_state.dart';

final class SettingsBloc extends Bloc<SettingsEvent, SettingsState> with DisposeBag {
  final SettingsRepository repository;
  final MindRepository mindRepository;
  final MindService mindService;
  final AuthService authService;

  SettingsBloc({
    required this.authService,
    required this.repository,
    required this.mindRepository,
    required this.mindService,
  }) : super(
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

    repository.stream.listen((settings) => add(SettingsGet())).disposed(by: this);
    authService.currentUserStream.listen((_) => add(SettingsGet())).disposed(by: this);
    Rx.combineLatest2(
      authService.currentUserStream,
      repository.stream.map((settings) => settings.isOfflineMode),
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
    final Iterable<Mind> minds = mindRepository.values;
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
    final Iterable<Mind> offlineMinds = await mindRepository.obtainNotUploadedToServerMinds();
    MindMessageWidget.isBlurred = !repository.value.isMindContentVisible;
    emit(
      SettingsDataState(
        offlineMinds: offlineMinds,
        settings: repository.value,
        isLoggedIn: authService.currentUser != null,
      ),
    );
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
    MindMessageWidget.isBlurred = event.isVisible;
    await repository.updateMindContentVisibility(event.isVisible);
  }

  FutureOr<void> _changeOfflineMode(
    SettingsChangeOfflineMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.updateOfflineMode(event.isOfflineMode);
  }

  FutureOr<void> _changeSettingsDarkMode(SettingsChangeIsDarkMode event, Emitter<SettingsState> emit) async {
    await repository.updateDarkMode(event.isDarkMode);
  }

  FutureOr<void> _sendWhatsNewIfNeeded(SettingGetWhatsNew event, Emitter<SettingsState> emit) async {
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

  FutureOr<void> _logout(SettingsLogout event, Emitter<SettingsState> emit) async {
    await authService.logout();
  }

  FutureOr<void> _getMindUploadCandidates(
    SettingsGetMindCandidatesToUpload event,
    Emitter<SettingsState> emit,
  ) async {
    final Iterable<Mind> uploadCandidates = await mindRepository.obtainNotUploadedToServerMinds();
    emit(SettingsOfflineMindsState(uploadCandidates));
  }

  Future<void> _uploadMindCandidates(
    SettingsUploadMindCandidates event,
    Emitter<SettingsState> emit,
  ) async {
    final Iterable<Mind> offlineMinds = await mindRepository.obtainNotUploadedToServerMinds();
    emit(SettingsLoadingState(true));

    final Iterable<Mind> rootOfflineMinds = offlineMinds.where((Mind mind) => mind.rootId == null);
    final Future<void> uploadRootMind = mindService.addAllMinds(values: rootOfflineMinds);
    final Iterable<Mind> childOfflineMinds = offlineMinds.where((Mind mind) => mind.rootId != null);
    final Future<void> uploadChildMinds = mindService.addAllMinds(values: childOfflineMinds);

    await uploadRootMind.then((_) async {
      await uploadChildMinds.then((_) async {
        await mindRepository
            .deleteMindsWhere((Mind mind) => offlineMinds.any((Mind candidate) => candidate.id == mind.id));
        await mindRepository.updateMinds(
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
    await repository.updateShouldShowTitles(event.value);
  }
}
