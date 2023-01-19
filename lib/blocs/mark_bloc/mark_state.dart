part of 'mark_bloc.dart';

abstract class MarkState {}

class ListMarkState extends MarkState {
  final Iterable<Mark> values;

  ListMarkState({required this.values});

  // Equatable.
  @override
  List<Object?> get props => [values];
}

class ErrorMarkState extends MarkState {
  final String text;

  ErrorMarkState({required this.text});

  @override
  List<Object?> get props => [text];
}

class SearchingMarkState extends MarkState {
  final bool enabled;
  final Iterable<Mark> values;
  final Iterable<Mark> filteredValues;

  SearchingMarkState({
    required this.enabled,
    required this.values,
    required this.filteredValues,
  });

  // Equatable.
  @override
  List<Object?> get props => [enabled, values, filteredValues];
}

class SuggestionsMarkState extends MarkState {
  final List<String> suggestionMarks;

  SuggestionsMarkState({required this.suggestionMarks});

  // Equatable.
  @override
  List<Object?> get props => [suggestionMarks];
}
