import 'dart:async';

import 'package:rememoji/services/keklist_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/services/main_service.dart';

class MainSupabaseService implements MainService {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<Iterable<Mind>> getMindList() async {
    _validateUserAuthorization();

    final List<dynamic> listOfEntities = await _client.from('minds').select();
    final List<Mind> minds = listOfEntities.map((e) => Mind.fromSupabaseJson(e)).toList();

    return minds;
  }

  @override
  Future<void> addMind(Mind mind) async {
    _validateUserAuthorization();

    await _client.from('minds').insert(mind.toSupabaseJson(userId: _client.auth.currentUser!.id));
  }

  @override
  Future<void> deleteMind(String id) async {
    _validateUserAuthorization();

    await _client.from('minds').delete().eq('uuid', id);
  }

  @override
  Future<void> addAllMinds({required Iterable<Mind> values}) async {
    _validateUserAuthorization();

    final Iterable<Map<String, dynamic>> listOfEntries =
        values.map((e) => e.toSupabaseJson(userId: _client.auth.currentUser!.id)).toList();

    await _client.from('minds').upsert(listOfEntries);
  }

  @override
  Future<void> editMind({required Mind mind}) async {
    _validateUserAuthorization();

    await _client.from('minds').update(mind.toSupabaseJson(userId: _client.auth.currentUser!.id)).eq('uuid', mind.id);
  }

  @override
  Future<void> deleteAllMinds() async {
    _validateAreYouDumb();
    _validateUserAuthorization();

    await _client.from('minds').delete().eq('user_id', _client.auth.currentUser!.id);
  }

  @override
  Future<void> deleteAccount() async {
    _validateAreYouDumb();
    _validateUserAuthorization();

    await _client.rpc('deleteUser');
  }

  void _validateAreYouDumb() {
    if (_client.auth.currentUser?.email == 'sashkn2@gmail.com') {
      throw KeklistError.dumbProtection();
    }
  }

  void _validateUserAuthorization() {
    if (_client.auth.currentUser == null) {
      throw KeklistError.nonAuthorized();
    }
  }

  // Future _generateError() {
  //   return Future.delayed(
  //     const Duration(seconds: 2),
  //     () {
  //       throw KeklistError.randomError();
  //     },
  //   );
  // }
}
