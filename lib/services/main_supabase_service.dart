import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/services/main_service.dart';

class MainSupabaseService implements MainService {
  final _client = Supabase.instance.client;
  late final Set<Mind> _cachedMinds = {};

  @override
  FutureOr<Iterable<Mind>> getMindList() async {
    if (_cachedMinds.isNotEmpty) {
      return _cachedMinds;
    }

    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    final List<dynamic> listOfEntities = await _client.from('minds').select();
    final List<Mind> minds = listOfEntities.map((e) => Mind.fromSupabaseJson(e)).toList();

    _cachedMinds
      ..clear()
      ..addAll(minds);

    return minds;
  }

  @override
  FutureOr<void> addMind(Mind mark) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').insert(
          mark.toSupabaseJson(userId: _client.auth.currentUser!.id),
        );

    _cachedMinds.add(mark);
  }

  @override
  FutureOr<void> removeMind(String id) async {
    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').delete().eq('uuid', id);

    _cachedMinds.removeWhere((element) => element.id == id);
  }

  @override
  FutureOr<void> addAll({required List<Mind> list}) async {
    await Future.forEach(list, (Mind element) async {
      await addMind(element);
    });
  }

  @override
  FutureOr<void> deleteAccount() async {
    // NOTE: защита от дурака.
    if (_client.auth.currentUser?.email != 'sashkn2@gmail.com') {
      return Future.error('Trying to delete admin account!');
    }
    await _client.rpc('deleteUser');
  }

  @override
  FutureOr<void> reset() {
    // Очищаем закешированные данные.
    _cachedMinds.clear();
  }
}
