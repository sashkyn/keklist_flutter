import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:zenmode/cubits/mark_searcher/mark_searcher_cubit.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/storage.dart';
import 'package:emojis/emoji.dart' as emojies_pub;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  late final IStorage _supabaseStorage;
  late final MarkSearcherCubit _searcherCubit;

  final List<Mark> _marks = [];

  MarkBloc({
    required IStorage storage,
    required MarkSearcherCubit searcherCubit,
  }) : super(ListMarkState(values: const [])) {
    _supabaseStorage = storage;
    _searcherCubit = searcherCubit;

    on<GetMarksMarkEvent>(_getMarks);
    on<CreateMarkEvent>(_createMark);
    on<DeleteMarkEvent>(_deleteMark);
    on<StartSearchMarkEvent>(_startSearch);
    on<StopSearchMarkEvent>(_stopSearch);
    on<EnterTextSearchMarkEvent>(_enterTextSearch);
    on<ChangeTextOfCreatingMarkEvent>(
      _changeTextOfCreatingMark,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 100)).asyncExpand(mapper),
    );
    on<ResetStorageMarkEvent>((event, emit) async {
      await _supabaseStorage.reset();
      _marks.clear();
      final state = ListMarkState(values: []);
      emit(state);  
    });
  }

  FutureOr<void> _deleteMark(DeleteMarkEvent event, emit) async {
    await _supabaseStorage.removeMark(event.uuid);
    final item = _marks.firstWhere((item) => item.id == event.uuid);
    _marks.remove(item);
    emit.call(ListMarkState(values: _marks));
  }

  FutureOr<void> _createMark(CreateMarkEvent event, emit) async {
    final mark = Mark(
      id: const Uuid().v4(),
      dayIndex: event.dayIndex,
      note: event.note.trim(),
      emoji: event.emoji,
      creationDate: DateTime.now().millisecondsSinceEpoch,
      sortIndex: _findMarksByDayIndex(event.dayIndex).length,
    );
    await _supabaseStorage.addMark(mark);
    _marks.add(mark);
    final newState = ListMarkState(values: _marks);
    emit.call(newState);
  }

  FutureOr<void> _getMarks(GetMarksMarkEvent event, emit) async {
    _marks
      ..clear()
      ..addAll(await _supabaseStorage.getMarks());
    final state = ListMarkState(values: _marks);
    emit(state);
  }

  FutureOr<void> _startSearch(StartSearchMarkEvent event, emit) async {
    emit.call(
      SearchingMarkState(
        enabled: true,
        values: _marks,
        filteredValues: const [],
      ),
    );
  }

  FutureOr<void> _stopSearch(StopSearchMarkEvent event, emit) async {
    emit.call(
      SearchingMarkState(
        enabled: false,
        values: _marks,
        filteredValues: const [],
      ),
    );
  }

  FutureOr<void> _enterTextSearch(EnterTextSearchMarkEvent event, Emitter<MarkState> emit) async {
    final filteredMarks = await _searcherCubit.searchMarkList(event.text);

    emit.call(
      SearchingMarkState(
        enabled: true,
        values: _marks,
        filteredValues: filteredMarks,
      ),
    );
  }

  List<String> _lastSuggestions = [];

  // TODO: переместить в MarkSearcherCubit;
  FutureOr<void> _changeTextOfCreatingMark(
    ChangeTextOfCreatingMarkEvent event,
    Emitter<MarkState> emit,
  ) {
    final List<String> suggestions = _marks
        .where((mark) => mark.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
        .map((mark) => mark.emoji)
        .toList()
        .distinct()
        .sorted((mark1, mark2) => _marks
            .where((element) => element.emoji == mark2)
            .length
            .compareTo(_marks.where((element) => element.emoji == mark1).length)) // NOTE: Сортировка очень дорогая
        .take(9)
        .toList();

    if (suggestions.isEmpty) {
      if (_marks.isEmpty) {
        _lastSuggestions = emojies_pub.Emoji.all().take(9).map((emoji) => emoji.char).toList();
      }
    } else {
      _lastSuggestions = suggestions;
    }
    emit.call(SuggestionsMarkState(suggestionMarks: _lastSuggestions));
  }

  List<Mark> _findMarksByDayIndex(int index) => _marks
      .where((item) => index == item.dayIndex)
      .mySortedBy(
        (it) => it.sortIndex,
      )
      .toList();
}

// MARK: Sorted by.

extension MyIterable<E> on Iterable<E> {
  Iterable<E> mySortedBy(Comparable Function(E e) key) => toList()
    ..sort(
      (a, b) => key(a).compareTo(key(b)),
    );
}
