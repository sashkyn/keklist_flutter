import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zenmode/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/services/main_service.dart';
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

  MindBloc({
    required MainService mainService,
    required MindSearcherCubit mindSearcherCubit,
  }) : super(MindListState(values: const [])) {
    _service = mainService;
    _searcherCubit = mindSearcherCubit;

    on<MindGetList>(_getMinds);
    on<MindCreate>(_createMind);
    on<MindDelete>(_deleteMind);
    on<MindStartSearch>(_startSearch);
    on<MindStopSearch>(_stopSearch);
    on<MindEnterSearchText>(_enterTextSearch);
    on<MindChangeCreateText>(
      _changeTextOfCreatingMark,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 100)).asyncExpand(mapper),
    );
    on<MindResetStorage>((event, emit) async {
      await _service.reset();
      _minds.clear();
      final state = MindListState(values: []);
      emit(state);
    });
  }

  FutureOr<void> _deleteMind(MindDelete event, emit) async {
    await _service.removeMind(event.uuid);
    _minds.removeWhere((item) => item.id == event.uuid);
    emit.call(MindListState(values: _minds));
  }

  FutureOr<void> _createMind(MindCreate event, emit) async {
    final mind = Mind(
      id: const Uuid().v4(),
      dayIndex: event.dayIndex,
      note: event.note.trim(),
      emoji: event.emoji,
      creationDate: DateTime.now().millisecondsSinceEpoch,
      sortIndex: _findMindsByDayIndex(event.dayIndex).length,
    );
    await _service.addMind(mind);
    _minds.add(mind);
    final newState = MindListState(values: _minds);
    emit.call(newState);
  }

  FutureOr<void> _getMinds(MindGetList event, emit) async {
    _minds
      ..clear()
      ..addAll(await _service.getMindList());
    final state = MindListState(values: _minds);
    emit(state);
  }

  FutureOr<void> _startSearch(MindStartSearch event, emit) async {
    emit.call(
      MindSearching(
        enabled: true,
        values: _minds,
        filteredValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(MindStopSearch event, emit) async {
    emit.call(
      MindSearching(
        enabled: false,
        values: _minds,
        filteredValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(MindEnterSearchText event, Emitter<MindState> emit) async {
    final filteredMinds = await _searcherCubit.searchMindList(event.text);

    emit(
      MindSearching(
        enabled: true,
        values: _minds,
        filteredValues: filteredMinds,
      ),
    );
  }

  List<String> _lastSuggestions = [];

  FutureOr<void> _changeTextOfCreatingMark(
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
    emit(MindSuggestions(suggestionMarks: _lastSuggestions));
  }

  List<Mind> _findMindsByDayIndex(int index) => _minds
      .where((item) => index == item.dayIndex)
      .mySortedBy(
        (it) => it.sortIndex,
      )
      .toList();
}

// NOTE: Sorted by.

extension ListIterable<E> on Iterable<E> {
  Iterable<E> mySortedBy(Comparable Function(E e) key) => toList()
    ..sort(
      (a, b) => key(a).compareTo(key(b)),
    );
}
