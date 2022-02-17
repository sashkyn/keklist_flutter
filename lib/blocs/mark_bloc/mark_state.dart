part of 'mark_bloc.dart';

abstract class MarkState {}

class ListMarkState extends MarkState {
  final List<Mark> values;

  ListMarkState({required this.values});
}

class UserSyncedMarkState extends MarkState {
  final bool isSync;

  UserSyncedMarkState({required this.isSync});
}

class ErrorMarkState extends MarkState {
  final String text;

  ErrorMarkState({required this.text});
}

class ConnectedToLocalStorageMarkState extends MarkState {}