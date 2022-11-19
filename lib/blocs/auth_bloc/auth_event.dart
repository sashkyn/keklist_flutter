part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class Login extends AuthEvent {
  final String email;

  const Login(this.email);
}

class Logout extends AuthEvent {}

class UserWasAppear extends AuthEvent {}

class UserWasDisapear extends AuthEvent {}
