import 'dart:async';
import 'dart:math';

import 'package:rememoji/services/keklist_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rememoji/services/entities/mind.dart';
import 'package:rememoji/services/main_service.dart';

class MainSupabaseService implements MainService {
  final _client = Supabase.instance.client;
  final _random = Random();

  @override
  Future<Iterable<Mind>> getMindList() async {
    if (_client.auth.currentUser == null) {
      throw KeklistError.nonAuthorized();
    }

    final List<dynamic> listOfEntities = await _client.from('minds').select();
    final List<Mind> minds = listOfEntities.map((e) => Mind.fromSupabaseJson(e)).toList();

    return minds;
  }

  @override
  Future<void> addMind(Mind mind) async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    if (_client.auth.currentUser == null) {
      throw KeklistError.nonAuthorized();
    }

    await _client.from('minds').insert(mind.toSupabaseJson(userId: _client.auth.currentUser!.id));
  }

  @override
  Future<void> deleteMind(String id) async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    if (_client.auth.currentUser == null) {
      throw KeklistError.nonAuthorized();
    }

    await _client.from('minds').delete().eq('uuid', id);
  }

  @override
  Future<void> addAllMinds({required List<Mind> list}) async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    if (_client.auth.currentUser == null) {
      throw KeklistError.nonAuthorized();
    }

    final Iterable<Map<String, dynamic>> listOfEntries =
        list.map((e) => e.toSupabaseJson(userId: _client.auth.currentUser!.id));
    await _client.from('minds').insert(listOfEntries);
  }

  @override
  Future<void> deleteAccount() async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    if (_client.auth.currentUser?.email == 'sashkn2@gmail.com') {
      throw KeklistError.dumbProtection();
    }
    return await _client.rpc('deleteUser');
  }

  Future? _generateRandomError() {
    return Future.delayed(
      const Duration(seconds: 2),
      () {
        throw KeklistError.randomError();
      },
    );
  }

  @override
  Future<void> editMind({required Mind mind}) async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    return await _client
        .from('minds')
        .update(mind.toSupabaseJson(userId: _client.auth.currentUser!.id))
        .eq('uuid', mind.id);
  }

  @override
  Future<void> deleteAllMinds() async {
    var randomError = _generateRandomError();
    if (randomError != null) {
      return randomError;
    }

    if (_client.auth.currentUser == null) {
      return Future.error('You did not auth to Supabase');
    }

    await _client.from('minds').delete().eq('user_id', _client.auth.currentUser!.id);
  }
}
