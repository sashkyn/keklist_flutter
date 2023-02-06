import 'package:bloc/bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/services/main_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MainService mainService;
  final SupabaseClient client;

  AuthBloc({
    required this.mainService,
    required this.client,
  }) : super(AuthInitial()) {
    client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user != null) {
        add(AuthUserAppearedInSession());
      } else {
        add(AuthUserGoneFromSession());
      }
    });
    on<AuthLoginWithEmailAndPassword>((event, emit) async {
      await client.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
    });
    on<AuthLoginWithEmail>((event, emit) async {
      await client.auth.signInWithOtp(
        email: event.email,
        emailRedirectTo: 'io.supabase.zenmode://login-callback/',
      );
    });
    on<AuthLoginWithSocialNetwork>((event, emit) async {
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
    on<AuthDeleteAccount>(
      (event, emit) async {
        await mainService.deleteAccount();
        add(AuthLogout());
      },
    );
    on<AuthLogout>((event, emit) async => await client.auth.signOut());
    on<AuthUserAppearedInSession>((event, emit) => emit(AuthLoggedIn()));
    on<AuthUserGoneFromSession>((event, emit) => emit(AuthLogouted()));
    on<AuthGetStatus>((event, emit) => emit(AuthCurrentStatus(isLoggedIn: client.auth.currentUser != null)));
  }

  Future<void> _signInWithWebOAuth(Provider provider) async {
    final result = await client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: 'io.supabase.zenmode://login-callback/',
    );

    final webResult = await FlutterWebAuth.authenticate(
      url: result.url.toString(),
      callbackUrlScheme: 'io.supabase.points',
      preferEphemeral: false,
    );

    final uri = Uri.parse(webResult);
    await client.auth.getSessionFromUrl(
      uri,
      storeSession: true,
    );

    // NOTE: теперь можно делать, но окошко с браузером не закрывается автоматически. Нужно понять почему...
    // await client.auth.signInWithOAuth(
    //   provider,
    //   authScreenLaunchMode: LaunchMode.inAppWebView,
    //   redirectTo: 'io.supabase.zenmode://login-callback/',
    // );
  }
}
