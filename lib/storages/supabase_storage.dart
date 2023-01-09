import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/storage.dart';

class SupabaseStorage implements IStorage {
  final _client = Supabase.instance.client;
  final List<Mark> _marks = List.empty(growable: true);

  @override
  FutureOr<List<Mark>> getMarks() async {
    if (_marks.isNotEmpty) {
      return _marks;
    }

    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    final List<dynamic> listOfEntities = await _client.from('minds').select().eq(
          'user_id',
          _client.auth.currentUser!.id,
        );

    final List<Mark> listOfMarks = listOfEntities.map((e) => Mark.fromSupabaseJson(e)).toList();

    _marks
      ..clear()
      ..addAll(listOfMarks);

    return listOfMarks;
  }

  @override
  FutureOr<void> addMark(Mark mark) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').insert(
          mark.toSupabaseJson(userId: _client.auth.currentUser!.id),
        );

    _marks.add(mark);
  }

  @override
  FutureOr<void> removeMark(String id) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').delete().eq('uuid', id);

    _marks.removeWhere((element) => element.id == id);
  }

  @override
  FutureOr<void> addAll({required List<Mark> list}) async {
    await Future.forEach(list, (Mark element) async {
      await addMark(element);
    });
  }
}
