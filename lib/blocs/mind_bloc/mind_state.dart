part of 'mind_bloc.dart';

abstract class MindState {}

class MindListState extends MindState {
  final Iterable<Mind> values;

  MindListState({required this.values});
}

class MindError extends MindState {
  final String text;

  MindError({required this.text});
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
}

class MindSuggestions extends MindState {
  final List<String> values;

  MindSuggestions({required this.values});
}
