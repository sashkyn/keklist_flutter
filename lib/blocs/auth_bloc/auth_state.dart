part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoggedIn extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLogouted extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthUserDeletedHimself extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthCurrentStatus extends AuthState {
  final bool isLoggedIn;

  @override
  List<Object?> get props => [isLoggedIn];

  const AuthCurrentStatus({required this.isLoggedIn});
}
