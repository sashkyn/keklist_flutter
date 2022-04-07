import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:emodzen/storages/entities/mark.dart';
import 'package:emodzen/storages/firebase_storage.dart';
import 'package:emodzen/storages/local_storage.dart';
import 'package:emodzen/storages/storage.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  final IStorage _localStorage = LocalStorage();
  late final IStorage _cloudStorage = FirebaseStorage(stand: _obtainStand());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userChangedSubscription;
  List<Mark> _marks = [];

  MarkBloc() : super(ListMarkState(values: [])) {
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
    emit.call(ListMarkState(values: _marks));
  }

  FutureOr<void> _getMarksFromCloudStorage(GetMarksFromCloudStorageMarkEvent event, emit) async {
    _marks.addAll(await _cloudStorage.getMarks());
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

  FutureOr<void> _enterTextSearch(EnterTextSearchMarkEvent event, Emitter<MarkState> emit) async {
    final filteredMarks = _marks
        .where((mark) => mark.note.trim().toLowerCase().contains(event.text.toLowerCase().trim()))
        .toList();

    emit.call(
      SearchingMarkState(
        enabled: true,
        values: _marks,
        filteredValues: filteredMarks,
      ),
    );
  }

  List<Mark> _findMarksByDayIndex(int index) =>
      _marks.where((item) => index == item.dayIndex).sortedBy((it) => it.sortIndex).toList();

  @override
  Future<void> close() {
    _userChangedSubscription?.cancel();
    return super.close();
  }

  String _obtainStand() {
    if (kReleaseMode) {
      return 'release';
    } else {
      return 'debug';
    }
  }
}

// MARK: Sorted by.

extension MyIterable<E> on Iterable<E> {
  Iterable<E> sortedBy(Comparable Function(E e) key) => toList()..sort((a, b) => key(a).compareTo(key(b)));
}
