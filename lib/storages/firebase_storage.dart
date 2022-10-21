// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/storage.dart';

class FirebaseStorage extends IStorage {
  final String stand;

  final DatabaseReference _databaseReference =
      FirebaseDatabase(databaseURL: 'https://keklist-881d8-default-rtdb.europe-west1.firebasedatabase.app/')
          .reference();

  FirebaseStorage({required this.stand});

  @override
  FutureOr<void> connect() async {
    // No need to connect.
  }

  @override
  FutureOr<void> addMark(Mark mark) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return;
    }
    return _databaseReference.child(stand).child(userId).child('marks').child(mark.uuid).set(mark.toFirebaseJson());
  }

  @override
  FutureOr<List<Mark>> getMarks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return [];
    }

    final List<Mark> marks = [];
    await _databaseReference.child(stand).child(userId).child('marks').once().then((snapshot) {
      snapshot.value.forEach((key, values) {
        final markMap = Map<String, dynamic>.from(values);
        markMap['id'] = key;
        marks.add(Mark.fromFirebaseJson(markMap));
      });
    });
    return marks;
  }

  @override
  FutureOr<void> removeMarkFromDay(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return;
    }
    return _databaseReference.child(stand).child(userId).child('marks').child(id).remove();
  }

  @override
  FutureOr<void> save({required List<Mark> list}) async {
    // TODO: Implement saving list of Marks
  }
}
