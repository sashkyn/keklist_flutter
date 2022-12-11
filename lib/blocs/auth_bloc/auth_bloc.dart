import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _client = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    _client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user != null) {
        add(UserUpdated());
      } else {
        add(UserDeleted());
      }
    });
    on<Login>((event, emit) async {
      await _client.auth.signInWithOtp(
        email: event.email,
        emailRedirectTo: 'io.supabase.zenmode://login-callback/',
      );
    });
    on<Logout>((event, emit) async => await _client.auth.signOut());
    on<UserUpdated>((event, emit) async => emit.call(SingedIn()));
    on<UserDeleted>((event, emit) async => emit.call(Logouted()));
  }
}
