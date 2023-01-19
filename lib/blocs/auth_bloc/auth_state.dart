part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class LoggedIn extends AuthState {}

class Logouted extends AuthState {}

class UserDeletedHimself extends AuthState {}

class CurrentUserAuthStatus extends AuthState {
  final bool isLoggedIn;

  const CurrentUserAuthStatus({required this.isLoggedIn});
}
