part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthLoginWithEmail extends AuthEvent {
  final String email;

  const AuthLoginWithEmail(this.email);
}

class AuthLoginWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  AuthLoginWithEmailAndPassword({
    required this.email,
    required this.password,
  });
}

class AuthLoginWithSocialNetwork extends AuthEvent {
  final SocialNetwork socialNetwork;

  AuthLoginWithSocialNetwork(this.socialNetwork);

  factory AuthLoginWithSocialNetwork.google() => AuthLoginWithSocialNetwork(SocialNetwork.google);
  factory AuthLoginWithSocialNetwork.facebook() => AuthLoginWithSocialNetwork(SocialNetwork.facebook);
  factory AuthLoginWithSocialNetwork.apple() => AuthLoginWithSocialNetwork(SocialNetwork.apple);
}

class AuthLogout extends AuthEvent {}

class AuthDeleteAccount extends AuthEvent {}

class AuthInternalUserAppearedInSession extends AuthEvent {}

class AuthInternalUserGoneFromSession extends AuthEvent {}

class AuthGetStatus extends AuthEvent {}

enum SocialNetwork {
  google,
  facebook,
  apple,
}
