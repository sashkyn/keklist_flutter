// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:keklist/storages/entities/mark.dart';
import 'package:keklist/storages/storage.dart';

class FirebaseStorage extends Storage {
  final String _stand;

  final DatabaseReference _databaseReference =
      FirebaseDatabase(databaseURL: 'https://keklist-881d8-default-rtdb.europe-west1.firebasedatabase.app/')
          .reference();

  FirebaseStorage(this._stand);

  @override
  Future<void> addMark(Mark mark) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return;
    }

    // final map = <String, dynamic>{};
    // map['day_index'] = mark.dayIndex;
    // map['emoji'] = mark.emoji;
    // map['note'] = mark.note;
    return _databaseReference.child(_stand).child(userId).child('marks').child(mark.uuid).set(mark.toJson());
  }

  @override
  Future<List<Mark>> getMarks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return [];
    }

    final List<Mark> marks = [];
    await _databaseReference.child(_stand).child(userId).child('marks').once().then((snapshot) {
      snapshot.value.forEach((key, values) {
        final markMap = Map<String, dynamic>.from(values);
        markMap['id'] = key;
        marks.add(Mark.fromJson(markMap));
      });
    });
    return marks;
  }

  @override
  Future<void> removeMarkFromDay(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('userId is null!');
      return;
    }
    return _databaseReference.child(_stand).child(userId).child('marks').child(id).remove();
  }
}
