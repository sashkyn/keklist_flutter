part of 'mark_bloc.dart';

abstract class MarkState {}

class ListMarkState extends MarkState {
  final List<Mark> values;

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

class SuggestionsMarkState extends MarkState {
  final List<String> suggestionMarks;

  SuggestionsMarkState({required this.suggestionMarks});

  // Equatable.
  @override
  List<Object?> get props => [suggestionMarks];
}
