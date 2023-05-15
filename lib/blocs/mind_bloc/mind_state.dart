part of 'mind_bloc.dart';

abstract class MindState {}

class MindList extends MindState {
  final Iterable<Mind> values;

  MindList({required this.values});
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

enum MindOperationType {
  create,
  edit,
  delete,
  fetch,
  uploadCachedData,
}

class MindOperationNotCompleted extends MindState with EquatableMixin {
  final Iterable<Mind> minds;
  final MindOperationType notCompleted;

  MindOperationNotCompleted({
    required this.minds,
    required this.notCompleted,
  });

  @override
  List<Object?> get props => [notCompleted, minds];

  @override
  bool? get stringify => true;
}

class MindServerOperationStarted extends MindState with EquatableMixin {
  final Iterable<Mind> minds;
  final MindOperationType type;

  MindServerOperationStarted({
    required this.minds,
    required this.type,
  });

  @override
  List<Object?> get props => [minds, type];

  @override
  bool? get stringify => true;
}

class MindOperationCompleted extends MindState with EquatableMixin {
  final Iterable<Mind> minds;
  final MindOperationType type;

  MindOperationCompleted({
    required this.minds,
    required this.type,
  });

  @override
  List<Object?> get props => [minds, type];

  @override
  bool? get stringify => true;
}
