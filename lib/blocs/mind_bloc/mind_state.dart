part of 'mind_bloc.dart';

abstract class MindState {}

class MindListState extends MindState {
  final Iterable<Mind> values;

  MindListState({required this.values});

  // Equatable.
  @override
  List<Object?> get props => [values];
}

class MindError extends MindState {
  final String text;

  MindError({required this.text});

  @override
  List<Object?> get props => [text];
}

class MindSearching extends MindState {
  final bool enabled;
  final Iterable<Mind> values;
  final Iterable<Mind> filteredValues;

  MindSearching({
    required this.enabled,
    required this.values,
    required this.filteredValues,
  });

  // Equatable.
  @override
  List<Object?> get props => [enabled, values, filteredValues];
}

class MindSuggestions extends MindState {
  final List<String> suggestionMarks;

  MindSuggestions({required this.suggestionMarks});

  // Equatable.
  @override
  List<Object?> get props => [suggestionMarks];
}
