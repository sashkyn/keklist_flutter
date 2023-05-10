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

  final Set<Mind> _minds = {};
  final Box<MindObject> _mindBox = Hive.box<MindObject>(HiveConstants.mindBoxName);
  final SettingsObject? _settings =
      Hive.box<SettingsObject>(HiveConstants.settingsBoxName).get(HiveConstants.settingsGlobalSettingsIndex);

  MindBloc({
    required MainService mainService,
    required MindSearcherCubit mindSearcherCubit,
  }) : super(MindListState(values: const [])) {
    _service = mainService;
    _searcherCubit = mindSearcherCubit;

    on<MindGetList>(_getMinds);
    on<MindCreate>(_createMind);
    on<MindDelete>(_deleteMind);
    on<MindEdit>(_editMind);
    on<MindStartSearch>(_startSearch);
    on<MindStopSearch>(_stopSearch);
    on<MindEnterSearchText>(_enterTextSearch);
    on<MindChangeCreateText>(
      _changeTextOfCreatingMind,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 100)).asyncExpand(mapper),
    );
  }

  FutureOr<void> _deleteMind(MindDelete event, emit) async {
    await _mindBox.delete(event.uuid);
    _minds.removeWhere((item) => item.id == event.uuid);
    emit.call(MindListState(values: _minds));

    if (!(_settings?.isOfflineMode ?? true)) {
      // Удаляем на сервере.
      await _service.deleteMind(event.uuid);
    }
  }

  FutureOr<void> _createMind(MindCreate event, emit) async {
    final Mind mind = Mind(
      id: const Uuid().v4(),
      dayIndex: event.dayIndex,
      note: event.note.trim(),
      emoji: event.emoji,
      creationDate: DateTime.now(),
      sortIndex: _findMindsByDayIndex(event.dayIndex).length,
    );
    _minds.add(mind);

    // Добавляем в локальное хранилище.
    _mindBox.put(
      mind.id,
      mind.toObject(),
    );

    final MindListState newState = MindListState(values: _minds);
    emit.call(newState);

    if (!(_settings?.isOfflineMode ?? true)) {
      // Добавляем на сервере.
      await _service.addMind(mind);
    }
  }

  FutureOr<void> _getMinds(MindGetList event, emit) async {
    // Подмешиваем элементы с локального хранилища.
    final Iterable<Mind> localMinds = _mindBox.values.map((object) => object.toMind());
    _minds.addAll(localMinds);
    final MindListState localStorageState = MindListState(values: _minds);
    emit(localStorageState);

    // Подмешиваем элементы с сервера.
    if (!(_settings?.isOfflineMode ?? true)) {
      final Iterable<Mind> serverMinds = await _service.getMindList();
      _minds.addAll(serverMinds);

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

      final MindListState networkState = MindListState(values: _minds);
      emit(networkState);
    }
  }

  FutureOr<void> _startSearch(MindStartSearch event, emit) async {
    emit.call(
      MindSearching(
        enabled: true,
        allValues: _minds,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(MindStopSearch event, emit) async {
    emit.call(
      MindSearching(
        enabled: false,
        allValues: _minds,
        resultValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(MindEnterSearchText event, Emitter<MindState> emit) async {
    final List<Mind> filteredMinds = await _searcherCubit.searchMindList(event.text);

    emit(
      MindSearching(
        enabled: true,
        allValues: _minds,
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
    final List<String> suggestions = _minds
        .where((mind) => mind.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
        .map((mind) => mind.emoji)
        .toList()
        .distinct()
        .sorted((emoji1, emoji2) => _minds
            .where((mind) => mind.emoji == emoji2)
            .length
            .compareTo(_minds.where((mind) => mind.emoji == emoji1).length)) // NOTE: Сортировка очень дорогая
        .take(count)
        .toList();

    if (suggestions.isEmpty) {
      if (_minds.isEmpty) {
        _lastSuggestions = emojies_pub.Emoji.all().take(count).map((emoji) => emoji.char).toList();
      }
    } else {
      _lastSuggestions = suggestions;
    }
    emit(MindSuggestions(values: _lastSuggestions));
  }

  List<Mind> _findMindsByDayIndex(int index) => _minds
      .where((item) => index == item.dayIndex)
      .mySortedBy(
        (it) => it.sortIndex,
      )
      .toList();

  Future<void> _editMind(
    MindEdit event,
    Emitter<MindState> emit,
  ) async {
    final Mind oldMind = _minds.firstWhere((mind) => mind.id == event.mind.id);
    final Mind editedMind = event.mind;
    _minds
      ..remove(oldMind)
      ..add(editedMind);

    // Удаляем из локального хранилища.
    _mindBox.get(event.mind.id)?.delete();

    // Обновляем стейт на блоке.
    emit(MindListState(values: _minds));

    if (!(_settings?.isOfflineMode ?? true)) {
      // Редактируем на сервере.
      await _service.edit(mind: event.mind);
    }
  }
}
