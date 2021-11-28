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

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  final Storage _localStorage = LocalStorage();
  late final Storage _cloudStorage = FirebaseStorage(stand: _obtainStand());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userChangedSubscription;
  List<Mark> _values = [];

  MarkBloc() : super(ListMarkState(markList: [])) {
    on<ConnectToLocalStorageMarkEvent>((event, emit) async {
      await _localStorage.connect();
      emit.call(ConnectedToLocalStorageMarkState());
    });
    on<StartListenSyncedUserMarkEvent>((event, emit) async {
      _userChangedSubscription?.cancel();
      _userChangedSubscription = _auth.authStateChanges().listen((user) => add(UserChangedMarkEvent(user: user)));
    });
    on<UserChangedMarkEvent>((event, emit) async => emit.call(UserSyncedMarkState(isSync: true)));
    on<ObtainMarksFromLocalStorageMarkEvent>((event, emit) async {
      _values = await _localStorage.getMarks();
      final state = ListMarkState(markList: _values);
      emit.call(state);
    });
    on<ObtainMarksFromCloudStorageMarkEvent>((event, emit) async {
      _values = await _cloudStorage.getMarks();
      final state = ListMarkState(markList: _values);
      emit.call(state);
    });
    on<CreateMarkEvent>((event, emit) async {
      final mark = Mark(
        uuid: const Uuid().v4(),
        dayIndex: event.dayIndex,
        note: event.note,
        emoji: event.emoji,
        creationDate: DateTime.now().millisecondsSinceEpoch,
        sortIndex: _findMarksByDayIndex(event.dayIndex).length,
      );
      await _localStorage.addMark(mark);
      await _cloudStorage.addMark(mark);
      _values.add(mark);
      emit.call(ListMarkState(markList: _values));
    });
    on<DeleteMarkEvent>((event, emit) async {
      await _localStorage.removeMarkFromDay(event.uuid);
      await _cloudStorage.removeMarkFromDay(event.uuid);
      final item = _values.firstWhere((item) => item.uuid == event.uuid);
      _values.remove(item);
      emit.call(ListMarkState(markList: _values));
    });
    //on<MarkEvent>((event, emit) async {});
    //on<MarkEvent>((event, emit) async {});
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
