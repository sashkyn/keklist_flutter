part of 'mind_bloc.dart';

abstract class MindState {}

class MindListState extends MindState {
  final Iterable<Mind> values;

  MindListState({required this.values});
}

class MindSearching extends MindState {
  final bool enabled;
  final Iterable<Mind> allValues;
  final List<Mind> resultValues;

  MindSearching({
    required this.enabled,
    required this.allValues,
    required this.resultValues,
  });
}

class MindSuggestions extends MindState {
  final List<String> values;

  MindSuggestions({required this.values});
}

// MARK: - Errors

enum MindServerErrorType {
  notCreated,
  notEdited,
  notDeleted,
  notLoaded,
}

enum MindServerErrorReason {
  notAuth,
  notConnected,
}

class MindServerError extends MindState with EquatableMixin {
  final MindServerErrorType type;
  final List<Mind> values;
  final MindServerErrorReason reason;

  MindServerError({
    required this.values,
    required this.type,
    required this.reason,
  });
  
  @override
  List<Object?> get props => [values, type, reason];

  @override
  bool? get stringify => true;
}
