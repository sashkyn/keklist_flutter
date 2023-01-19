part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginWithEmail extends AuthEvent {
  final String email;

  const AuthLoginWithEmail(this.email);
}

class AuthLoginWithSocialNetwork extends AuthEvent {
  final SocialNetwork socialNetwork;

  AuthLoginWithSocialNetwork(this.socialNetwork);
}

class AuthLogout extends AuthEvent {}

class AuthDeleteUser extends AuthEvent {}

class AuthUserAppearedInSession extends AuthEvent {}

class AuthUserGoneFromSession extends AuthEvent {}

class AuthGetStatus extends AuthEvent {}

enum SocialNetwork {
  google,
  facebook,
  apple,
}
