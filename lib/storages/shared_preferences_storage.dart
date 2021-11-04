// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'entities/mark.dart';

// class SharedPreferencesStorage {
//   late SharedPreferences _prefs;

//   Future<void> connect() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   void addMark(Mark mark) {
//     final marks = getMarks();
//     marks.add(mark);
//     _prefs.setString('marks', json.encode(marks));
//   }

//   void removeMarkFromDay(int dayIndex, String emoji) {
//     final marks = getMarks();
//     final markToRemove = marks.firstWhere((i) => i.emoji == emoji && i.dayIndex == dayIndex);
//     marks.remove(markToRemove);
//     _prefs.setString('marks', json.encode(marks));
//   }

//   List<Mark> getMarks() {
//     final marksJSON = _prefs.getString('marks');
//     if (marksJSON == null) {
//       return [];
//     }
//     final List<dynamic> list = json.decode(marksJSON);
//     final marks = list.map((item) => Mark.fromJson(item)).toList();
//     return marks;
//   }
// }
