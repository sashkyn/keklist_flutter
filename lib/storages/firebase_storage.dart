import 'package:firebase_database/firebase_database.dart';
import 'package:keklist/storages/entities/mark.dart';
import 'package:keklist/storages/storage.dart';

class FirebaseStorage extends Storage {
  final DatabaseReference _databaseReference =
      FirebaseDatabase(databaseURL: 'https://keklist-881d8-default-rtdb.europe-west1.firebasedatabase.app/')
          .reference();

  @override
  Future<void> addMark(Mark mark) async {
    final map = <String, dynamic>{};
    map['day_index'] = mark.dayIndex;
    map['emoji'] = mark.emoji;
    map['note'] = mark.note;
    return _databaseReference.child('debug').child('sashkyn').child("marks").child(mark.uuid).set(map);
  }

  @override
  Future<List<Mark>> getMarks() async {
    final List<Mark> marks = [];
    await _databaseReference.child("debug").child("sashkyn").child("marks").orderByKey().once().then((snapshot) {
      snapshot.value.forEach((key, values) {
        final markMap = Map<String, dynamic>.from(values);
        markMap['id'] = key;
        marks.add(Mark.fromJson(markMap));
      });
    });
    return marks;
  }

  @override
  Future<void> removeMarkFromDay(String id) {
    return _databaseReference.child("debug").child("sashkyn").child("marks").child(id).remove();
  }
}
