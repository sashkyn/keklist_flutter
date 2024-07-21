import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keklist/domain/services/auth/auth_service.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/domain/limitations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> with DisposeBag {
  final MindService mainService;
  final AuthService authRepository;
  final SupabaseClient _client = Supabase.instance.client;

  AuthBloc({
    required this.mainService,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthLoginWithEmailAndPassword>(_authWithEmailAndPassword);
    on<AuthLoginWithEmail>(_authWithEmail);
    on<AuthLoginWithSocialNetwork>(_authWithSocialNetwork);
    on<AuthDeleteAccount>(_deleteAccount);
    on<AuthLogout>(_logout);
    on<AuthGetStatus>(_getStatus);
    authRepository.currentUserStream.listen((event) => add(AuthGetStatus())).disposed(by: this);
  }

  void _getStatus(event, emit) {
    emit(AuthCurrentState(isLoggedIn: authRepository.currentUser != null));
  }

  Future<void> _logout(event, emit) async => await authRepository.logout();

  Future<void> _deleteAccount(event, emit) async {
    await mainService.deleteAccount();
    add(AuthLogout());
  }

  FutureOr<void> _authWithEmailAndPassword(event, emit) {
    return authRepository.loginWithCredentials(email: event.email, password: event.password);
  }

  FutureOr<void> _authWithEmail(event, emit) {
    return authRepository.loginWithOTP(email: event.email);
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

    // if (DeviceUtils.safeGetPlatform() == SupportedPlatform.android && provider == OAuthProvider.google) {
    //   await _signInWithGoogle();
    //   return;
    // }

    final OAuthResponse result = await authRepository.getAuthWebURL(socialProvider: provider);

    final String webResult = await FlutterWebAuth2.authenticate(
      url: result.url.toString(),
      callbackUrlScheme: 'io.supabase.zenmode',
      options: const FlutterWebAuth2Options(
        preferEphemeral: false,
      ),
    );

    final Uri uri = Uri.parse(webResult);
    await authRepository.loginWithSocialNetwork(uri);

    // NOTE: теперь можно делать, но окошко с браузером не закрывается автоматически. Нужно понять почему...
    // NOTE: пока не понятно, как открывать это в боттом шите :(
    // await client.auth.signInWithOAuth(
    //   provider,
    //   redirectTo: 'io.supabase.zenmode',
    //   authScreenLaunchMode: LaunchMode.inAppBrowserView,
    // );
  }

  /// TODO:
  /// Wait response from Google about adding logo
  /// Test on iOS, make only for android if needed
  Future<AuthResponse> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final idToken = googleAuth?.idToken;

    if (idToken == null) {
      throw 'Google: No ID Token found.';
    }

    return Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth?.accessToken,
    );
  }

  Future<AuthResponse> _signInWithApple() async {
    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Could not find ID Token from generated credential.');
    }

    return _client.auth.signInWithIdToken(
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
