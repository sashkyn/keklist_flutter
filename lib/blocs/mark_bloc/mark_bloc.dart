import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/firebase_storage.dart';
import 'package:zenmode/storages/local_storage.dart';
import 'package:zenmode/storages/storage.dart';
import 'package:emojis/emoji.dart' as emojies_pub;
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  final IStorage _localStorage = LocalStorage();
  late final IStorage _cloudStorage = FirebaseStorage(stand: _obtainStand());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userChangedSubscription;
  List<Mark> _marks = [];

  MarkBloc() : super(ListMarkState(values: const [])) {
    on<ConnectToLocalStorageMarkEvent>(_connectToLocalStorage);
    on<StartListenSyncedUserMarkEvent>(_startListenSyncedUser);
    on<UserChangedMarkEvent>(_userWasSynced);
    on<GetMarksFromLocalStorageMarkEvent>(_getMarksFromLocalStorage);
    on<GetMarksFromCloudStorageMarkEvent>(_getMarksFromCloudStorage);
    on<CreateMarkEvent>(_createMark);
    on<DeleteMarkEvent>(_deleteMark);
    on<StartSearchMarkEvent>(_startSearch);
    on<StopSearchMarkEvent>(_stopSearch);
    on<EnterTextSearchMarkEvent>(_enterTextSearch);
    on<ChangeTextOfCreatingMarkEvent>(
      _changeTextOfCreatingMark,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 100)).asyncExpand(mapper),
    );
  }

  FutureOr<void> _userWasSynced(UserChangedMarkEvent event, emit) async =>
      emit.call(UserSyncedMarkState(isSync: event.user != null));

  FutureOr<void> _deleteMark(DeleteMarkEvent event, emit) async {
    await _localStorage.removeMarkFromDay(event.uuid);
    await _cloudStorage.removeMarkFromDay(event.uuid);
    final item = _marks.firstWhere((item) => item.uuid == event.uuid);
    _marks.remove(item);
    emit.call(ListMarkState(values: _marks));
  }

  FutureOr<void> _createMark(CreateMarkEvent event, emit) async {
    final mark = Mark(
      uuid: const Uuid().v4(),
      dayIndex: event.dayIndex,
      note: event.note.trim(),
      emoji: event.emoji,
      creationDate: DateTime.now().millisecondsSinceEpoch,
      sortIndex: _findMarksByDayIndex(event.dayIndex).length,
    );
    await _localStorage.addMark(mark);
    await _cloudStorage.addMark(mark);
    _marks.add(mark);
    final newState = ListMarkState(values: _marks);
    // TODO: Почему-то иногда newState и oldState одинаковые на момент отправки.
    emit.call(newState);
  }

  FutureOr<void> _getMarksFromCloudStorage(GetMarksFromCloudStorageMarkEvent event, emit) async {
    _marks
      ..addAll(await _cloudStorage.getMarks())
      ..distinct();
    _marks = _marks.distinct();
    final state = ListMarkState(values: _marks);
    emit.call(state);

    // TODO: сохранять в сторадж только тех что нет в нём.
    await _localStorage.connect();
    emit.call(ConnectedToLocalStorageMarkState());
    await _localStorage.save(list: _marks);
  }

  FutureOr<void> _getMarksFromLocalStorage(GetMarksFromLocalStorageMarkEvent event, emit) async {
    _marks.addAll(await _localStorage.getMarks());
    _marks = _marks.distinct();
    final state = ListMarkState(values: _marks);
    emit.call(state);
  }

  FutureOr<void> _startListenSyncedUser(StartListenSyncedUserMarkEvent event, emit) async {
    _userChangedSubscription?.cancel();
    _userChangedSubscription = _auth.authStateChanges().listen((user) => add(UserChangedMarkEvent(user: user)));
  }

  FutureOr<void> _connectToLocalStorage(ConnectToLocalStorageMarkEvent event, emit) async {
    await _localStorage.connect();
    emit.call(ConnectedToLocalStorageMarkState());
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

  final _emojiParser = EmojiParser();

  FutureOr<void> _enterTextSearch(EnterTextSearchMarkEvent event, Emitter<MarkState> emit) async {
    final filteredMarks = _marks.where((mark) {
      // Note condition.
      final noteCondition = mark.note.trim().toLowerCase().contains(event.text.toLowerCase().trim());

      // Emoji condition.
      final emojies = _emojiParser.parseEmojis(event.text);
      final emojiCondintion = emojies.any((emoji) => mark.emoji == emoji);

      return noteCondition || emojiCondintion;
    }).toList();

    emit.call(
      SearchingMarkState(
        enabled: true,
        values: _marks,
        filteredValues: filteredMarks,
      ),
    );
  }

  List<String> _lastSuggestions = [];

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

  List<Mark> _findMarksByDayIndex(int index) =>
      _marks.where((item) => index == item.dayIndex).mySortedBy((it) => it.sortIndex).toList();

  @override
  Future<void> close() {
    _userChangedSubscription?.cancel();
    return super.close();
  }

  String _obtainStand() {
    return 'release';
    // if (kReleaseMode) {
    //   return 'release';
    // } else {
    //   return 'debug';
    // }
  }
}

// MARK: Sorted by.

extension MyIterable<E> on Iterable<E> {
  Iterable<E> mySortedBy(Comparable Function(E e) key) => toList()..sort((a, b) => key(a).compareTo(key(b)));
}
