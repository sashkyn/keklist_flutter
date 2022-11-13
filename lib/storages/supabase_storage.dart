import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/storage.dart';

class SupabaseStorage implements IStorage {
  final _client = Supabase.instance.client;

  @override
  Future<void> connect() async {
    // No need to connect.
  }

  @override
  FutureOr<List<Mark>> getMarks() async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    final response = await _client.from('minds').select().eq(
          'user_id',
          _client.auth.currentUser!.id,
        );

    if (response.error != null) {
      return Future.error(response.error!.message);
    }

    if (response.data == null) {
      return [];
    }

    final List<dynamic> listOfEntities = response.data;
    final List<Mark> listOfMarks = listOfEntities
        .map(
          (e) => Mark.fromSupabaseJson(e),
        )
        .toList();

    return listOfMarks;
  }

  @override
  FutureOr<void> addMark(Mark mark) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    final response = await _client.from('minds').insert(
          mark.toSupabaseJson(userId: _client.auth.currentUser!.id),
        );

    if (response.error != null) {
      return Future.error(response.error!.message);
    }
  }

  @override
  FutureOr<void> removeMarkFromDay(String id) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').delete().eq('uuid', id);
  }

  @override
  FutureOr<void> save({required List<Mark> list}) async {
    await Future.forEach(list, (Mark element) async {
      await addMark(element);
    });
  }
}
