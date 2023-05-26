part of 'auth_bloc.dart';

// TODO: не работает с Equatable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthCurrentState extends AuthState {
  final bool isLoggedIn;

  AuthCurrentState(this.isLoggedIn);
}

class AuthUserDeletedHimself extends AuthState {}
