import 'dart:async';

import 'package:keklist/domain/repositories/auth/kek_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthMinotaur {
  KekUser? get value;
  Stream<KekUser?> get stream;
  FutureOr<OAuthResponse> getAuthWebURL({required OAuthProvider socialProvider});
  FutureOr<void> loginWithCredentials({required String email, required String password});
  FutureOr<void> loginWithOTP({required String email});
  FutureOr<void> loginWithSocialNetwork(Uri uri);
  FutureOr<void> logout();
}

final class AuthSupabaseMinotaur implements AuthMinotaur {
  final SupabaseClient _client;

  AuthSupabaseMinotaur({required SupabaseClient client}) : _client = client;

  @override
  KekUser? get value {
    final User? supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }
    return KekUser(email: supabaseUser.email);
  }

  @override
  Stream<KekUser?> get stream => _client.auth.onAuthStateChange.map(
        (event) {
          final User? supabaseUser = event.session?.user;
          if (supabaseUser == null) {
            return null;
          }
          return KekUser(email: supabaseUser.email);
        },
      );

  @override
  FutureOr<void> loginWithCredentials({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  FutureOr<void> loginWithSocialNetwork(Uri url) async {
    await _client.auth.getSessionFromUrl(url, storeSession: true);
  }

  @override
  FutureOr<void> loginWithOTP({required String email}) {
    return _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.zenmode://login-callback/',
    );
  }

  @override
  FutureOr<void> logout() async {
    return await _client.auth.signOut();
  }

  @override
  FutureOr<OAuthResponse> getAuthWebURL({required OAuthProvider socialProvider}) async {
    return await _client.auth.getOAuthSignInUrl(
      provider: socialProvider,
      redirectTo: 'io.supabase.zenmode://login-callback/',
    );
  }
}
