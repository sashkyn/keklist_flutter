import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:emodzen/storages/entities/mark.dart';
import 'package:emodzen/storages/firebase_storage.dart';
import 'package:emodzen/storages/local_storage.dart';
import 'package:emodzen/storages/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  final LocalStorage _localStorage = LocalStorage();
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
    //on<MarkEvent>((event, emit) async {});
    //on<MarkEvent>((event, emit) async {});
    //on<MarkEvent>((event, emit) async {});
    //on<MarkEvent>((event, emit) async {});
  }

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
