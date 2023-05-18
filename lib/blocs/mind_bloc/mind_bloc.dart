import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:rememoji/helpers/mind_utils.dart';
import 'package:rememoji/services/hive/constants.dart';
import 'package:rememoji/services/hive/entities/mind/mind_object.dart';
import 'package:rememoji/services/hive/entities/settings/settings_object.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rememoji/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/services/main_service.dart';
import 'package:emojis/emoji.dart' as emojies_pub;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

part 'mind_event.dart';
part 'mind_state.dart';

class MindBloc extends Bloc<MindEvent, MindState> {
  late final MainService _service;
  late final MindSearcherCubit _searcherCubit;

  final Set<Mind> _serverMinds = {};
  final Set<Mind> _localMinds = {};

  final Box<MindObject> _mindBox = Hive.box<MindObject>(HiveConstants.mindBoxName);
  final SettingsObject? _settings =
      Hive.box<SettingsObject>(HiveConstants.settingsBoxName).get(HiveConstants.settingsGlobalSettingsIndex);

  MindBloc({
    required MainService mainService,
    required MindSearcherCubit mindSearcherCubit,
  }) : super(MindList(values: const [])) {
    _service = mainService;
    _searcherCubit = mindSearcherCubit;

    on<MindGetList>(_getMinds);
    on<MindCreate>(_createMind);
    on<MindDelete>(_deleteMind);
    on<MindDeleteAllMinds>(_deleteAllMindsFromServer);
    on<MindClearCache>(_clearCache);
    on<MindEdit>(_editMind);
    on<MindStartSearch>(_startSearch);
    on<MindStopSearch>(_stopSearch);
    on<MindEnterSearchText>(
      _enterTextSearch,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 200)).asyncExpand(mapper),
    );
    on<MindUploadCandidates>(_uploadCandidates);
    on<MindChangeCreateText>(
      _changeTextOfCreatingMind,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 200)).asyncExpand(mapper),
    );
    on<MindGetUploadCandidates>(_getUploadCandidates);
  }

  Future<void> _getMinds(MindGetList event, Emitter<MindState> emit) async {
    final Iterable<Mind> localMinds = _mindBox.values.map((object) => object.toMind());
    _localMinds.addAll(localMinds);
    _emitMindList(emit);

    // Подмешиваем элементы с сервера.
    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(
          minds: [],
          type: MindOperationType.fetch,
        ),
      );
      await _service.getMindList().then((final Iterable<Mind> serverMinds) {
        _serverMinds.addAll(serverMinds);

        // Обновляем локальное хранилище.
        _mindBox.putAll(
          Map.fromEntries(
            serverMinds.map(
              (mind) => MapEntry(
                mind.id,
                mind.toObject(),
              ),
            ),
          ),
        );
        _localMinds.addAll(serverMinds);

        _emitMindList(emit);

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
    final Mind mind = Mind(
      id: const Uuid().v4(),
      dayIndex: event.dayIndex,
      note: event.note.trim(),
      emoji: event.emoji,
      creationDate: DateTime.now().toUtc(),
      sortIndex: (_findMindsByDayIndex(event.dayIndex).map((mind) => mind.sortIndex).maxOrNull ?? -1) + 1,
    );
    _serverMinds.add(mind);

    // Добавляем в локальное хранилище.
    _mindBox.put(
      mind.id,
      mind.toObject(),
    );

    final MindList newState = MindList(values: _serverMinds);
    emit.call(newState);

    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(
          minds: [mind],
          type: MindOperationType.create,
        ),
      );
      // Добавляем на сервере.
      await _service.addMind(mind).onError((error, _) {
        // Роллбек
        _serverMinds.remove(mind);
        _mindBox.delete(mind.id);
        _emitMindList(emit);

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

  Future<void> _deleteMind(MindDelete event, Emitter<MindState> emit) async {
    await _mindBox.delete(event.uuid);
    final Mind mindToDelete = _serverMinds.firstWhere((item) => item.id == event.uuid);
    _serverMinds.remove(mindToDelete);
    _localMinds.remove(mindToDelete);
    _emitMindList(emit);

    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(
          minds: [mindToDelete],
          type: MindOperationType.delete,
        ),
      );
      // Удаляем на сервере.
      await _service.deleteMind(event.uuid).then((_) {
        emit(
          MindOperationCompleted(
            minds: [mindToDelete],
            type: MindOperationType.delete,
          ),
        );
      }).onError((error, _) {
        // Роллбек
        _localMinds.add(mindToDelete);
        _serverMinds.add(mindToDelete);
        _mindBox.put(
          mindToDelete.id,
          mindToDelete.toObject(),
        );
        _emitMindList(emit);

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
        allValues: _serverMinds,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(MindStopSearch event, emit) async {
    emit(
      MindSearching(
        enabled: false,
        allValues: _serverMinds,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(MindEnterSearchText event, Emitter<MindState> emit) async {
    final List<Mind> filteredMinds = await _searcherCubit.searchMindList(event.text);

    emit(
      MindSearching(
        enabled: true,
        allValues: _serverMinds,
        resultValues: filteredMinds,
      ),
    );
  }

  List<String> _lastSuggestions = [];

  FutureOr<void> _changeTextOfCreatingMind(
    MindChangeCreateText event,
    Emitter<MindState> emit,
  ) {
    const count = 9;
    final List<String> suggestions = _serverMinds
        .where((mind) => mind.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
        .map((mind) => mind.emoji)
        .toList()
        .distinct()
        .sorted((emoji1, emoji2) => _serverMinds
            .where((mind) => mind.emoji == emoji2)
            .length
            .compareTo(_serverMinds.where((mind) => mind.emoji == emoji1).length)) // NOTE: Сортировка очень дорогая
        .take(count)
        .toList();

    if (suggestions.isEmpty) {
      if (_serverMinds.isEmpty) {
        _lastSuggestions = emojies_pub.Emoji.all().take(count).map((emoji) => emoji.char).toList();
      }
    } else {
      _lastSuggestions = suggestions;
    }
    emit(MindSuggestions(values: _lastSuggestions));
  }

  List<Mind> _findMindsByDayIndex(int index) => _serverMinds
      .where((item) => index == item.dayIndex)
      .mySortedBy(
        (it) => it.sortIndex,
      )
      .toList();

  Future<void> _editMind(
    MindEdit event,
    Emitter<MindState> emit,
  ) async {
    final Mind oldMind = _serverMinds.firstWhere((mind) => mind.id == event.mind.id);
    final Mind editedMind = event.mind;
    _serverMinds
      ..remove(oldMind)
      ..add(editedMind);
    _localMinds
      ..remove(oldMind)
      ..add(editedMind);

    // Удаляем из локального хранилища.
    _mindBox.get(event.mind.id)?.delete();

    _emitMindList(emit);

    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(minds: [event.mind], type: MindOperationType.edit),
      );

      // Редактируем на сервере.
      await _service
          .editMind(mind: event.mind)
          .then((_) => emit(
                MindOperationCompleted(
                  minds: [event.mind],
                  type: MindOperationType.edit,
                ),
              ))
          .onError(
        (error, _) {
          // Роллбек
          _serverMinds
            ..remove(editedMind)
            ..add(oldMind);
          _localMinds
            ..remove(editedMind)
            ..add(oldMind);
          _mindBox.add(editedMind.toObject());

          _emitMindList(emit);

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

  void _emitMindList(Emitter<MindState> emit) {
    final Set<Mind> unionedMinds = _serverMinds.union(_localMinds);
    emit(
      MindList(values: unionedMinds),
    );
  }

  Future<void> _deleteAllMindsFromServer(
    MindDeleteAllMinds event,
    Emitter<MindState> emit,
  ) {
    emit(
      MindServerOperationStarted(
        minds: [],
        type: MindOperationType.deleteAll,
      ),
    );
    return _service.deleteAllMinds().then(
      (_) {
        _serverMinds.clear();
        _emitMindList(emit);
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
    await _mindBox.clear().then(
      (int countOfDeletedItems) {
        _localMinds.clear();
        _emitMindList(emit);
        return emit(
          MindOperationCompleted(
            minds: [],
            type: MindOperationType.clearCache,
          ),
        );
      },
    ).onError(
      (error, _) => emit(
        MindOperationError(
          minds: [],
          notCompleted: MindOperationType.clearCache,
        ),
      ),
    );
  }

  Future<void> _uploadCandidates(
    MindUploadCandidates event,
    Emitter<MindState> emit,
  ) {
    final Iterable<Mind> localMinds = event.minds;
    emit(
      MindServerOperationStarted(
        minds: localMinds,
        type: MindOperationType.uploadCachedData,
      ),
    );
    return _service.addAllMinds(list: localMinds).then(
      (_) {
        emit(
          MindOperationCompleted(
            minds: localMinds,
            type: MindOperationType.uploadCachedData,
          ),
        );
      },
    ).onError(
      (error, _) {
        emit(
          MindOperationError(
            minds: localMinds,
            notCompleted: MindOperationType.uploadCachedData,
          ),
        );
      },
    );
  }

  Future<void> _getUploadCandidates(
    MindGetUploadCandidates event,
    Emitter<MindState> emit,
  ) async {
    if (_localMinds.isEmpty) {
      emit(MindCandidatesForUpload(values: []));
      return;
    }

    final Iterable<Mind> uploadCandidates = _localMinds.difference(_serverMinds).map(
          (mind) => mind.copyWith(
            id: const Uuid().v4(),
          ),
        );
    if (uploadCandidates.isEmpty) {
      emit(MindCandidatesForUpload(values: []));
      return;
    }

    emit(
      MindCandidatesForUpload(values: uploadCandidates),
    );
  }
}
