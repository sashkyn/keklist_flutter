import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  late SharedPreferences _prefs;

  Future<void> connect() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void addPattern(Pattern pattern) {
    final patterns = getPatterns();
    if (patterns.contains(pattern)) {
      return;
    }
    patterns.add(pattern);
    _prefs.setString('patterns', json.encode(patterns));
  }

  void removeFirstFindedPattern(String emoji) {
    final patterns = getPatterns();
    final patternToRemove = patterns.firstWhere((i) => i.emoji == emoji);
    patterns.remove(patternToRemove);
    _prefs.setString('patterns', json.encode(patterns));
  }

  List<Pattern> getPatterns() {
    final patternsJSON = _prefs.getString('patterns');
    if (patternsJSON == null) {
      return [];
    }
    final List<dynamic> list = json.decode(patternsJSON);
    final patterns = list.map((item) => Pattern.fromJson(item)).toList();
    return patterns;
  }

  void addMark(Mark mark) {
    final marks = getMarks();
    marks.add(mark);
    _prefs.setString('marks', json.encode(marks));
  }

  void removeMarkFromDay(int dayIndex, String emoji) {
    final marks = getMarks();
    final markToRemove = marks.firstWhere((i) => i.emoji == emoji && i.dayIndex == dayIndex);
    marks.remove(markToRemove);
    _prefs.setString('marks', json.encode(marks));
  }

  List<Mark> getMarks() {
    final marksJSON = _prefs.getString('marks');
    if (marksJSON == null) {
      return [];
    }
    final List<dynamic> list = json.decode(marksJSON);
    final marks = list.map((item) => Mark.fromJson(item)).toList();
    return marks;
  }
}

class Mark {
  final String emoji;
  final String note;
  final int dayIndex;

  Mark({
    required this.note,
    required this.emoji,
    required this.dayIndex,
  });

  Mark.fromJson(Map<String, dynamic> json)
      : emoji = json['emoji'],
        dayIndex = json['day_index'],
        note = json['note'];

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'note': note,
      'day_index': dayIndex,
    };
  }
}

class Pattern {
  final String emoji;
  final String note;

  Pattern({
    required this.note,
    required this.emoji,
  });

  Pattern.fromJson(Map<String, dynamic> json)
      : emoji = json['emoji'],
        note = json['note'];

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'note': note,
    };
  }
}
