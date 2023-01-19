part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoggedIn extends AuthState {}

class AuthLogouted extends AuthState {}

class AuthUserDeletedHimself extends AuthState {}

class AuthCurrentStatus extends AuthState {
  final bool isLoggedIn;

  const AuthCurrentStatus({required this.isLoggedIn});
}
