part of 'mark_bloc.dart';

abstract class MarkState extends Equatable {}

class ListMarkState extends MarkState {
  final List<Mark> values;

  ListMarkState({required this.values});

  // Equatable.
  @override
  List<Object?> get props => [values];
}

class UserSyncedMarkState extends MarkState {
  final bool isSync;

  UserSyncedMarkState({required this.isSync});

  // Equatable.
  @override
  List<Object?> get props => [isSync];
}

class ErrorMarkState extends MarkState {
  final String text;

  ErrorMarkState({required this.text});

  @override
  List<Object?> get props => [text];
}

class ConnectedToLocalStorageMarkState extends MarkState {
  // Equatable.
  @override
  List<Object?> get props => [];
}

class SearchingMarkState extends MarkState {
  final bool enabled;
  final List<Mark> values;
  final List<Mark> filteredValues;

  SearchingMarkState({
    required this.enabled,
    required this.values,
    required this.filteredValues,
  });

  // Equatable.
  @override
  List<Object?> get props => [enabled, values, filteredValues];
}
