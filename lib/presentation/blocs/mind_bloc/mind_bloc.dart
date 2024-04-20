import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:home_widget/home_widget.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:keklist/presentation/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';
import 'package:emojis/emoji.dart' as emojies_pub;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'mind_event.dart';
part 'mind_state.dart';

final class MindBloc extends Bloc<MindEvent, MindState> with DisposeBag {
  late final MindService _service;
  late final MindSearcherCubit _searcherCubit;
  late final MindRepository _repository;
  late final SettingsRepository _settingsRepository;

  MindBloc({
    required MindService mainService,
    required MindSearcherCubit mindSearcherCubit,
    required MindRepository mindRepository,
    required SettingsRepository settingsRepository,
  }) : super(MindList(values: const [])) {
    _service = mainService;
    _searcherCubit = mindSearcherCubit;
    _repository = mindRepository;
    _settingsRepository = settingsRepository;
    on<MindGetList>(_getMinds);
    on<MindUpdateMobileWidgets>(_updateMobileWidgets);
    on<MindCreate>(_createMind);
    on<MindDelete>(_deleteMind);
    on<MindDeleteAllMinds>(_deleteAllMindsFromServer);
    on<MindClearCache>(_clearCache);
    on<MindEdit>(_editMind);
    on<MindStartSearch>(_startSearch);
    on<MindStopSearch>(_stopSearch);
    on<MindEnterSearchText>(
      _enterTextSearch,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 300)).asyncExpand(mapper),
    );
    on<MindUploadCandidates>(_uploadCandidates);
    on<MindChangeCreateText>(
      _changeTextOfCreatingMind,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper),
    );
    on<MindGetUploadCandidates>(_getUploadCandidates);
    on<MindInternalGetListFromCache>((_, emit) => _emitMindList(emit));
    _repository.stream.listen((event) => add(MindInternalGetListFromCache())).disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }

  Future<void> _getMinds(MindGetList event, Emitter<MindState> emit) async {
    _emitMindList(emit);

    if (!(_settingsRepository.value.isOfflineMode)) {
      emit(
        MindServerOperationStarted(
          minds: [],
          type: MindOperationType.fetch,
        ),
      );

      await _service.getMindList().then((Iterable<Mind> serverMinds) async {
        await _repository.updateMinds(minds: serverMinds.toList(), isUploadedToServer: true);
        emit(
          MindOperationCompleted(
            minds: [],
            type: MindOperationType.fetch,
          ),
        );
      }).onError(
        (error, _) {
          emit(
            MindOperationError(
              minds: [],
              notCompleted: MindOperationType.fetch,
            ),
          );
        },
      );
    }
  }

  Future<void> _createMind(MindCreate event, Emitter<MindState> emit) async {
    final int sortIndex =
        ((await _findMindsByDayIndex(event.dayIndex)).map((mind) => mind.sortIndex).maxOrNull ?? -1) + 1;
    final Mind mind = Mind(
        id: const Uuid().v4(),
        dayIndex: event.dayIndex,
        note: event.note.trim(),
        emoji: event.emoji,
        creationDate: DateTime.now().toUtc(),
        sortIndex: sortIndex,
        rootId: event.rootId);
    _repository.createMind(mind: mind, isUploadedToServer: false);

    if (!(_settingsRepository.value.isOfflineMode)) {
      emit(
        MindServerOperationStarted(
          minds: [mind],
          type: MindOperationType.create,
        ),
      );
      // Добавляем на сервере.
      await _service.createMind(mind).then((_) {
        _repository.updateUploadedOnServerMind(mindId: mind.id, isUploadedToServer: true);
        MindOperationCompleted(
          minds: [mind],
          type: MindOperationType.create,
        );
      }).onError((error, _) async {
        // Роллбек
        await _repository.deleteMind(mindId: mind.id);

        // Обработка ошибки
        emit(
          MindOperationError(
            minds: [mind],
            notCompleted: MindOperationType.create,
          ),
        );
      });
    }
  }

  // TODO: удалить каскадно все остальное
  Future<void> _deleteMind(MindDelete event, Emitter<MindState> emit) async {
    _repository.deleteMind(mindId: event.mind.id);

    if (!(_settingsRepository.value.isOfflineMode)) {
      final Mind mindToDelete = event.mind;
      emit(
        MindServerOperationStarted(
          minds: [mindToDelete],
          type: MindOperationType.delete,
        ),
      );
      // Удаляем на сервере.
      await _service.deleteMind(mindToDelete.id).then((_) {
        emit(
          MindOperationCompleted(
            minds: [mindToDelete],
            type: MindOperationType.delete,
          ),
        );
      }).onError((error, _) async {
        // Роллбек
        await _repository.createMind(mind: mindToDelete, isUploadedToServer: true);

        // Обработка ошибки
        emit(
          MindOperationError(
            minds: [mindToDelete],
            notCompleted: MindOperationType.delete,
          ),
        );
      });
    }
  }

  FutureOr<void> _startSearch(MindStartSearch event, emit) async {
    emit(
      MindSearching(
        enabled: true,
        allValues: _repository.values,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(MindStopSearch event, emit) async {
    emit(
      MindSearching(
        enabled: false,
        allValues: _repository.values,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(MindEnterSearchText event, Emitter<MindState> emit) async {
    final List<Mind> filteredMinds = await _searcherCubit.searchMindList(event.text);
    emit(
      MindSearching(
        enabled: true,
        allValues: _repository.values,
        resultValues: filteredMinds,
      ),
    );
  }

  List<String> _lastSuggestions = [];

  FutureOr<void> _changeTextOfCreatingMind(
    MindChangeCreateText event,
    Emitter<MindState> emit,
  ) async {
    const count = 9;
    final List<Mind> minds = _repository.values.toList();
    final List<String> suggestions = _repository.values
        .where((Mind mind) => mind.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
        .map((Mind mind) => mind.emoji)
        .toList()
        .distinct()
        .sorted((String emoji1, String emoji2) => minds
            .where((Mind mind) => mind.emoji == emoji2)
            .length
            .compareTo(minds.where((mind) => mind.emoji == emoji1).length)) // NOTE: Сортировка очень дорогая
        .take(count)
        .toList();

    if (suggestions.isEmpty) {
      if (minds.isEmpty) {
        _lastSuggestions = emojies_pub.Emoji.all().take(count).map((emoji) => emoji.char).toList();
      }
    } else {
      _lastSuggestions = suggestions;
    }
    emit(MindSuggestions(values: _lastSuggestions));
  }

  Future<List<Mind>> _findMindsByDayIndex(int index) async {
    final minds = await _repository.obtainMindsWhere(
      (mind) => mind.dayIndex == index && mind.rootId == null,
    )
      ..sortedByFunction((it) => it.sortIndex);
    return minds.toList();
  }

  Future<void> _editMind(
    MindEdit event,
    Emitter<MindState> emit,
  ) async {
    final Mind editedMind = event.mind;

    final Mind? oldMind = await _repository.obtainMind(mindId: editedMind.id);
    if (oldMind == null) {
      emit(
        MindOperationError(
          minds: [editedMind],
          notCompleted: MindOperationType.edit,
        ),
      );
      return;
    }

    await _repository.updateMind(mind: editedMind, isUploadedToServer: false);

    if (!(_settingsRepository.value.isOfflineMode)) {
      emit(
        MindServerOperationStarted(minds: [event.mind], type: MindOperationType.edit),
      );

      // Редактируем на сервере.
      await _service.editMind(mind: event.mind).then((_) {
        emit(
          MindOperationCompleted(
            minds: [event.mind],
            type: MindOperationType.edit,
          ),
        );
      }).onError(
        (error, _) async {
          // Роллбек
          await _repository.updateUploadedOnServerMind(
            mindId: editedMind.id,
            isUploadedToServer: true,
          );

          // Обработка ошибки
          emit(
            MindOperationError(
              minds: [editedMind],
              notCompleted: MindOperationType.edit,
            ),
          );
        },
      );
    }
  }

  Future<void> _emitMindList(Emitter<MindState> emit) async {
    emit(MindList(values: _repository.values));
  }

  Future<void> _deleteAllMindsFromServer(
    MindDeleteAllMinds event,
    Emitter<MindState> emit,
  ) async {
    emit(
      MindServerOperationStarted(
        minds: [],
        type: MindOperationType.deleteAll,
      ),
    );
    await _service.deleteAllMinds().then(
      (_) async {
        await _repository.updateUploadedOnServerMinds(
          minds: _repository.values,
          isUploadedToServer: false,
        );
        emit(
          MindOperationCompleted(
            minds: [],
            type: MindOperationType.deleteAll,
          ),
        );
      },
    ).onError(
      (error, _) {
        emit(
          MindOperationError(
            minds: [],
            notCompleted: MindOperationType.deleteAll,
          ),
        );
      },
    );
  }

  Future<void> _clearCache(MindClearCache event, Emitter<MindState> emit) async {
    emit(
      MindServerOperationStarted(
        minds: [],
        type: MindOperationType.clearCache,
      ),
    );
    await _repository.deleteMinds();
    emit(
      MindOperationCompleted(
        minds: [],
        type: MindOperationType.clearCache,
      ),
    );
  }

  Future<void> _uploadCandidates(
    MindUploadCandidates event,
    Emitter<MindState> emit,
  ) async {
    final Iterable<Mind> uploadCandidates = await _repository.obtainNotUploadedToServerMinds();
    emit(
      MindServerOperationStarted(
        minds: uploadCandidates,
        type: MindOperationType.uploadCachedData,
      ),
    );

    final Iterable<Mind> rootMinds = uploadCandidates.where((Mind mind) => mind.rootId == null);

    final Future<void> uploadRootTasks = _service.addAllMinds(values: rootMinds).onError(
      (error, _) {
        emit(
          MindOperationError(
            minds: uploadCandidates,
            notCompleted: MindOperationType.uploadCachedData,
          ),
        );
      },
    );

    final Iterable<Mind> notRootMinds = uploadCandidates.where((Mind mind) => mind.rootId != null);

    final Future<void> uploadNonRootTasks = _service.addAllMinds(values: notRootMinds).onError(
      (error, _) {
        emit(
          MindOperationError(
            minds: uploadCandidates,
            notCompleted: MindOperationType.uploadCachedData,
          ),
        );
      },
    );

    await uploadRootTasks.then((_) async {
      await uploadNonRootTasks.then((_) async {
        await _repository
            .deleteMindsWhere((Mind mind) => uploadCandidates.any((Mind candidate) => candidate.id == mind.id));
        await _repository.updateMinds(
          minds: uploadCandidates.toList(),
          isUploadedToServer: true,
        );
        emit(
          MindOperationCompleted(
            minds: uploadCandidates,
            type: MindOperationType.uploadCachedData,
          ),
        );
      }).onError((error, _) {
        emit(
          MindOperationError(
            minds: uploadCandidates,
            notCompleted: MindOperationType.uploadCachedData,
          ),
        );
      });
    }).onError((error, _) {
      emit(
        MindOperationError(
          minds: uploadCandidates,
          notCompleted: MindOperationType.uploadCachedData,
        ),
      );
    });
  }

  Future<void> _getUploadCandidates(
    MindGetUploadCandidates event,
    Emitter<MindState> emit,
  ) async {
    final Iterable<Mind> uploadCandidates = await _repository.obtainNotUploadedToServerMinds();
    if (uploadCandidates.isEmpty) {
      emit(MindCandidatesForUpload(values: []));
      return;
    }
    emit(MindCandidatesForUpload(values: uploadCandidates));
  }

  Future<void> _updateMobileWidgets(MindUpdateMobileWidgets event, Emitter<MindState> emit) async {
    if (DeviceUtils.safeGetPlatform() != SupportedPlatform.iOS) {
      return;
    }
    final Iterable<Mind> todayMinds =
        await _repository.obtainMindsWhere((mind) => mind.dayIndex == MindUtils.getTodayIndex());

    final List<String> todayMindJSONList = todayMinds
        .map(
          (mind) => json.encode(
            mind,
            toEncodable: (i) => mind.toShortJson(),
          ),
        )
        .toList();
    await HomeWidget.saveWidgetData(
      'mind_today_widget_today_minds',
      todayMindJSONList,
    );
    await HomeWidget.updateWidget(iOSName: PlatformConstants.iosMindDayWidgetName);
  }
}
