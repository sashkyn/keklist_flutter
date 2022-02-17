import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:emodzen/storages/entities/mark.dart';
import 'package:emodzen/storages/firebase_storage.dart';
import 'package:emodzen/storages/local_storage.dart';
import 'package:emodzen/storages/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  final IStorage _localStorage = LocalStorage();
  late final IStorage _cloudStorage = FirebaseStorage(stand: _obtainStand());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userChangedSubscription;
  List<Mark> _values = [];

  MarkBloc() : super(ListMarkState(values: [])) {
    on<ConnectToLocalStorageMarkEvent>(_connectToLocalStorage);
    on<StartListenSyncedUserMarkEvent>(_startListenSyncedUser);
    on<UserChangedMarkEvent>(_userWasSynced);
    on<ObtainMarksFromLocalStorageMarkEvent>(_obtainMarksFromLocalStorage);
    on<ObtainMarksFromCloudStorageMarkEvent>(_obtainMarksFromCloudStorage);
    on<CreateMarkEvent>(_createMark);
    on<DeleteMarkEvent>(_deleteMark);
  }

  FutureOr<void> _userWasSynced(UserChangedMarkEvent event, emit) async =>
      emit.call(UserSyncedMarkState(isSync: event.user != null));

  FutureOr<void> _deleteMark(DeleteMarkEvent event, emit) async {
    await _localStorage.removeMarkFromDay(event.uuid);
    await _cloudStorage.removeMarkFromDay(event.uuid);
    final item = _values.firstWhere((item) => item.uuid == event.uuid);
    _values.remove(item);
    emit.call(ListMarkState(values: _values));
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
    _values.add(mark);
    emit.call(ListMarkState(values: _values));
  }

  FutureOr<void> _obtainMarksFromCloudStorage(ObtainMarksFromCloudStorageMarkEvent event, emit) async {
    _values.addAll(await _cloudStorage.getMarks());
    _values = _values.distinct();
    final state = ListMarkState(values: _values);
    emit.call(state);
    // TODO: сохранять в сторадж только тех что нет в нём.
    await _localStorage.connect();
    emit.call(ConnectedToLocalStorageMarkState());
    await _localStorage.save(list: _values);
  }

  FutureOr<void> _obtainMarksFromLocalStorage(ObtainMarksFromLocalStorageMarkEvent event, emit) async {
    _values.addAll(await _localStorage.getMarks());
    _values = _values.distinct();
    final state = ListMarkState(values: _values);
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

  List<Mark> _findMarksByDayIndex(int index) =>
      _values.where((item) => index == item.dayIndex).sortedBy((it) => it.sortIndex).toList();

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
