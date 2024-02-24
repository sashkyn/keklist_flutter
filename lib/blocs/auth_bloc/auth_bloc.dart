import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/limitaions.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keklist/services/main_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with DisposeBag {
  final MainService mainService;
  final SupabaseClient client;

  AuthBloc({
    required this.mainService,
    required this.client,
  }) : super(AuthInitial()) {
    on<AuthLoginWithEmailAndPassword>(_authWithEmailAndPassword);
    on<AuthLoginWithEmail>(_authWithEmail);
    on<AuthLoginWithSocialNetwork>(_authWithSocialNetwork);
    on<AuthDeleteAccount>(_deleteAccount);
    on<AuthLogout>(_logout);
    on<AuthGetStatus>(_getStatus);
    on<AuthInternalUserAppearedInSession>((event, emit) => emit(AuthCurrentState(true)));
    on<AuthInternalUserGoneFromSession>((event, emit) => emit(AuthCurrentState(false)));
    client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user != null) {
        add(AuthInternalUserAppearedInSession());
      } else {
        add(AuthInternalUserGoneFromSession());
      }
    }).disposed(by: this);
  }

  void _getStatus(event, emit) {
    if (client.auth.currentUser != null) {
      emit(AuthCurrentState(true));
    } else {
      emit(AuthCurrentState(false));
    }
  }

  Future<void> _logout(event, emit) async => await client.auth.signOut();

  Future<void> _deleteAccount(event, emit) async {
    await mainService.deleteAccount();
    add(AuthLogout());
  }

  Future<void> _authWithEmailAndPassword(event, emit) {
    return client.auth.signInWithPassword(
      email: event.email,
      password: event.password,
    );
  }

  Future<void> _authWithEmail(event, emit) {
    return client.auth.signInWithOtp(
      email: event.email,
      emailRedirectTo: 'io.supabase.zenmode://login-callback/',
    );
  }

  Future<void> _authWithSocialNetwork(event, emit) async {
    switch (event.socialNetwork) {
      case KeklistSupportedSocialNetwork.google:
        return _signInWithWebOAuth(OAuthProvider.google);
      case KeklistSupportedSocialNetwork.facebook:
        return _signInWithWebOAuth(OAuthProvider.facebook);
      case KeklistSupportedSocialNetwork.apple:
        return _signInWithWebOAuth(OAuthProvider.apple);
    }
  }

  Future<void> _signInWithWebOAuth(OAuthProvider provider) async {
    if (provider == OAuthProvider.apple) {
      await _signInWithApple();
      return;
    }

    if (provider == OAuthProvider.google) {
      await _signInWithGoogle();
      return;
    }

    final OAuthResponse result = await client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: 'io.supabase.zenmode://login-callback/',
    );

    final String webResult = await FlutterWebAuth2.authenticate(
      url: result.url.toString(),
      callbackUrlScheme: 'io.supabase.zenmode',
      options: const FlutterWebAuth2Options(
        preferEphemeral: false,
      ),
    );

    final Uri uri = Uri.parse(webResult);
    await client.auth.getSessionFromUrl(
      uri,
      storeSession: true,
    );

    // NOTE: теперь можно делать, но окошко с браузером не закрывается автоматически. Нужно понять почему...
    // NOTE: пока не понятно, как открывать это в боттом шите :(
    // await client.auth.signInWithOAuth(
    //   provider,
    //   redirectTo: 'io.supabase.zenmode',
    //   authScreenLaunchMode: LaunchMode.inAppBrowserView,
    // );
  }

  /// TODO:
  /// Add scope only for email
  /// Wait responce from Google about adding logo
  /// Test on iOS, make only for android if needed
  Future<AuthResponse> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'Google: No ID Token found.';
    }

    return client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  Future<AuthResponse> _signInWithApple() async {
    final rawNonce = client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Could not find ID Token from generated credential.');
    }

    return client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }
}
