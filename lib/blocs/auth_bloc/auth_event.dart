part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LoginWithEmail extends AuthEvent {
  final String email;

  const LoginWithEmail(this.email);
}

class LoginWithSocialNetwork extends AuthEvent {
  final SocialNetwork socialNetwork;

  LoginWithSocialNetwork(this.socialNetwork);
}

class Logout extends AuthEvent {}

class UserUpdated extends AuthEvent {}

class UserDeleted extends AuthEvent {}

class GetAuthStatus extends AuthEvent {}

enum SocialNetwork {
  google,
  facebook,
  apple,
}
