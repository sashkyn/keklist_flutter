import 'dart:convert';

import 'package:emodzen/storages/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entities/mark.dart';

class SharedPreferencesStorage extends Storage {
  late SharedPreferences _prefs;

  @override
  Future<void> connect() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> addMark(Mark mark) async {
    final marks = await getMarks();
    marks.add(mark);
    _prefs.setString('marks', json.encode(marks));
  }

  @override
  Future<List<Mark>> getMarks() async {
    final marksJSON = _prefs.getString('marks');
    if (marksJSON == null) {
      return [];
    }
    final List<dynamic> list = json.decode(marksJSON);
    final marks = list.map((item) => Mark.fromJson(item)).toList();
    return marks;
  }

  @override
  Future<void> removeMarkFromDay(String id) async {
    final marks = await getMarks();
    final markToRemove = marks.firstWhere((i) => i.uuid == id);
    marks.remove(markToRemove);
    _prefs.setString('marks', json.encode(marks));
  }
}
