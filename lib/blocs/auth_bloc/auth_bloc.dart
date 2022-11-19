import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _client = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    _client.auth.onAuthStateChange.listen((event) {
      if (kDebugMode) {
        print(event.event);
      }
      if (event.session?.user != null) {
        add(UserWasAppear());
      } else {
        add(UserWasDisapear());
      }
    });
    on<Login>((event, emit) async {
      await _client.auth.signInWithOtp(
        email: event.email,
        emailRedirectTo: 'io.supabase.zenmode://login-callback/',
      );
    });
    on<Logout>((event, emit) async {
      await _client.auth.signOut();
    });
    on<UserWasAppear>((event, emit) async {
      emit.call(SingedIn());
    });
    on<UserWasDisapear>((event, emit) async {
      emit.call(Logouted());
    });
  }
}
