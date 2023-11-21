import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rememoji/services/main_service.dart';

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
      case SocialNetwork.google:
        return _signInWithWebOAuth(Provider.google);
      case SocialNetwork.facebook:
        return _signInWithWebOAuth(Provider.facebook);
      case SocialNetwork.apple:
        return _signInWithWebOAuth(Provider.apple);
    }
  }

  // @override
  // void emit(AuthState state) {
  //   print('----------');
  //   print('emit old state ${this.state}');
  //   print('emit new state ${state}');
  //   print('emit ${this.state == state}');

  //   // ignore: invalid_use_of_visible_for_testing_member
  //   super.emit(state);
  // }

  Future<void> _signInWithWebOAuth(Provider provider) async {
    final OAuthResponse result = await client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: 'io.supabase.zenmode://login-callback/',
    );

    final String webResult = await FlutterWebAuth2.authenticate(
      url: result.url.toString(),
      callbackUrlScheme: 'io.supabase.points',
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
    // await client.auth.signInWithOAuth(
    //   provider,
    //   authScreenLaunchMode: LaunchMode.inAppWebView,
    //   redirectTo: 'io.supabase.zenmode://login-callback/',
    // );
  }

  @override
  Future<void> close() {
    cancelSubscriptions();

    return super.close();
  }
}
