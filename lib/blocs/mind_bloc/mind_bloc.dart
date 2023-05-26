import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
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

part 'mind_event.dart';
part 'mind_state.dart';

class MindBloc extends Bloc<MindEvent, MindState> with DisposeBag {
  late final MainService _service;
  late final MindSearcherCubit _searcherCubit;

  final Box<MindObject> _mindBox = Hive.box<MindObject>(HiveConstants.mindBoxName);
  final SettingsObject? _settings =
      Hive.box<SettingsObject>(HiveConstants.settingsBoxName).get(HiveConstants.settingsGlobalSettingsIndex);

  Iterable<MindObject> get _mindObjects => _mindBox.values;
  Stream<dynamic> get _mindStream =>
      _mindBox.watch().map((event) => event.value).debounceTime(const Duration(milliseconds: 100));

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
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper),
    );
    on<MindUploadCandidates>(_uploadCandidates);
    on<MindChangeCreateText>(
      _changeTextOfCreatingMind,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper),
    );
    on<MindGetUploadCandidates>(_getUploadCandidates);
    on<MindInternalGetListFromCache>(
      (event, emit) {
        _emitMindList(emit);
      },
    );

    _mindStream.listen((event) {
      add(MindInternalGetListFromCache());
    }).disposed(by: this);
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }

  Future<void> _getMinds(MindGetList event, Emitter<MindState> emit) async {
    _emitMindList(emit);

    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(
          minds: [],
          type: MindOperationType.fetch,
        ),
      );
      await _service.getMindList().then((Iterable<Mind> serverMinds) {
        // Обновляем локальное хранилище.
        _mindBox.putAll(
          Map.fromEntries(
            serverMinds.map(
              (mind) => MapEntry(
                mind.id,
                mind.toObject(isUploadedToServer: true),
              ),
            ),
          ),
        );

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

    // Добавляем в локальное хранилище.
    final MindObject object = mind.toObject(isUploadedToServer: false);
    _mindBox.put(mind.id, object);

    if (!(_settings?.isOfflineMode ?? true)) {
      emit(
        MindServerOperationStarted(
          minds: [mind],
          type: MindOperationType.create,
        ),
      );
      // Добавляем на сервере.
      await _service.addMind(mind).then((value) {
        object
          ..isUploadedToServer = true
          ..save();
        MindOperationCompleted(
          minds: [mind],
          type: MindOperationType.create,
        );
      }).onError((error, _) {
        // Роллбек
        object.delete();

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
    final MindObject? object = _mindBox.get(event.uuid);
    if (object == null) {
      return;
    }
    object.delete();

    if (!(_settings?.isOfflineMode ?? true)) {
      final Mind mindToDelete = object.toMind();
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
        _mindBox.put(
          mindToDelete.id,
          object,
        );

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
        allValues: _mindObjects.map((e) => e.toMind()),
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(MindStopSearch event, emit) async {
    emit(
      MindSearching(
        enabled: false,
        allValues: _mindObjects.map((e) => e.toMind()),
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(MindEnterSearchText event, Emitter<MindState> emit) async {
    final List<Mind> filteredMinds = await _searcherCubit.searchMindList(event.text);

    emit(
      MindSearching(
        enabled: true,
        allValues: _mindObjects.map((e) => e.toMind()),
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
    final List<String> suggestions = _mindObjects
        .where((MindObject mind) => mind.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
        .map((MindObject mind) => mind.emoji)
        .toList()
        .distinct()
        .sorted((String emoji1, String emoji2) => _mindObjects
            .where((MindObject mind) => mind.emoji == emoji2)
            .length
            .compareTo(_mindObjects.where((mind) => mind.emoji == emoji1).length)) // NOTE: Сортировка очень дорогая
        .take(count)
        .toList();

    if (suggestions.isEmpty) {
      if (_mindObjects.isEmpty) {
        _lastSuggestions = emojies_pub.Emoji.all().take(count).map((emoji) => emoji.char).toList();
      }
    } else {
      _lastSuggestions = suggestions;
    }
    emit(MindSuggestions(values: _lastSuggestions));
  }

  List<Mind> _findMindsByDayIndex(int index) => _mindBox.values
      .where((item) => index == item.dayIndex)
      .mySortedBy(
        (it) => it.sortIndex,
      )
      .map(
        (e) => e.toMind(),
      )
      .toList();

  Future<void> _editMind(
    MindEdit event,
    Emitter<MindState> emit,
  ) async {
    final Mind editedMind = event.mind;

    final MindObject? oldMind = _mindBox.get(event.mind.id);
    if (oldMind == null) {
      emit(
        MindOperationError(
          minds: [editedMind],
          notCompleted: MindOperationType.edit,
        ),
      );
      return;
    }

    _mindBox.get(event.mind.id)
      ?..note = editedMind.note
      ..emoji = editedMind.emoji
      ..save();

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
          editedMind.toObject(isUploadedToServer: true).save();

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
    final Iterable<Mind> minds = _mindObjects.map((item) => item.toMind());
    emit(
      MindList(values: minds),
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
      (_) async {
        _mindBox.values.map((object) => object
          ..isUploadedToServer = false
          ..save());
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
    await _mindBox.clear().then(
      (int countOfDeletedItems) {
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
  ) async {
    // INFO: здесь листы потому что видимо в листах присутствуют ссылки на объекты а он не создает новых,
    // хз надо разобраться
    final Iterable<MindObject> objects =
        _mindBox.values.where((MindObject mind) => !mind.isUploadedToServer).toList(growable: false);
    final Iterable<Mind> uploadCandidates = objects.map((MindObject mind) => mind.toMind()).toList(growable: false);
    emit(
      MindServerOperationStarted(
        minds: uploadCandidates,
        type: MindOperationType.uploadCachedData,
      ),
    );

    final Iterable<Mind> refreshedUploadCandidates =
        uploadCandidates.map((Mind mind) => mind.copyWith(id: const Uuid().v4())).toList(growable: false);

    await _service.addAllMinds(values: refreshedUploadCandidates).then(
      (_) async {
        await _mindBox.deleteAll(uploadCandidates.map((Mind mind) => mind.id));

        final Map<String, MindObject> refreshedCandidateObjects = refreshedUploadCandidates.fold({}, (
          Map<String, MindObject> map,
          Mind mind,
        ) {
          map[mind.id] = mind.toObject(isUploadedToServer: true);
          return map;
        });
        await _mindBox.putAll(refreshedCandidateObjects);

        emit(
          MindOperationCompleted(
            minds: refreshedUploadCandidates,
            type: MindOperationType.uploadCachedData,
          ),
        );
      },
    ).onError(
      (error, _) {
        emit(
          MindOperationError(
            minds: uploadCandidates,
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
    if (_mindObjects.isEmpty) {
      emit(MindCandidatesForUpload(values: []));
      return;
    }

    final Iterable<Mind> uploadCandidates =
        _mindObjects.where((MindObject object) => !object.isUploadedToServer).map((MindObject mind) => mind.toMind());
    if (uploadCandidates.isEmpty) {
      emit(MindCandidatesForUpload(values: []));
      return;
    }

    emit(
      MindCandidatesForUpload(values: uploadCandidates),
    );
  }
}
