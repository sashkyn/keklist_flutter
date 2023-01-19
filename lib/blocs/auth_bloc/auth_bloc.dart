import 'package:bloc/bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _client = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    _client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user != null) {
        add(UserAppearedInSession());
      } else {
        add(UserGoneFromSession());
      }
    });
    on<LoginWithEmail>((event, emit) async {
      await _client.auth.signInWithOtp(
        email: event.email,
        emailRedirectTo: 'io.supabase.zenmode://login-callback/',
      );
    });
    on<LoginWithSocialNetwork>((event, emit) async {
      switch (event.socialNetwork) {
        case SocialNetwork.google:
          await _signInWithWebOAuth(Provider.google);
          break;
        case SocialNetwork.facebook:
          await _signInWithWebOAuth(Provider.facebook);
          break;
        case SocialNetwork.apple:
          await _signInWithWebOAuth(Provider.apple);
          break;
      }
    });
    on<DeleteUser>(
      (event, emit) async {
        await _client.rpc('deleteUser');
        add(Logout());
      },
    );
    on<Logout>((event, emit) async => await _client.auth.signOut());
    on<UserAppearedInSession>((event, emit) => emit(LoggedIn()));
    on<UserGoneFromSession>((event, emit) => emit(Logouted()));
    on<GetAuthStatus>((event, emit) => emit(CurrentUserAuthStatus(isLoggedIn: _client.auth.currentUser != null)));
  }

  Future<void> _signInWithWebOAuth(Provider provider) async {
    final result = await _client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: 'io.supabase.zenmode://login-callback/',
    );

    final webResult = await FlutterWebAuth.authenticate(
      url: result.url.toString(),
      callbackUrlScheme: 'io.supabase.points',
      preferEphemeral: false,
    );

    final uri = Uri.parse(webResult);
    await _client.auth.getSessionFromUrl(
      uri,
      storeSession: true,
    );
  }
}
