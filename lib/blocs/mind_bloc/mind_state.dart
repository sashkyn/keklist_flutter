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

enum MindOperationNotCompletedType {
  notCreated,
  notEdited,
  notDeleted,
  notLoaded,
}

class MindOperationNotCompleted extends MindState with EquatableMixin {
  final Mind? mind;
  final MindOperationNotCompletedType type;

  MindOperationNotCompleted({
    required this.mind,
    required this.type,
  });

  @override
  List<Object?> get props => [type, mind];

  @override
  bool? get stringify => true;
}

class MindServerOperationStarted extends MindState with EquatableMixin {
  final Mind mind;

  MindServerOperationStarted({required this.mind});

  @override
  List<Object?> get props => [mind];

  @override
  bool? get stringify => true;
}

class MindServerOperationCompleted extends MindState with EquatableMixin {
  final Mind? mind;

  MindServerOperationCompleted({required this.mind});

  @override
  List<Object?> get props => [mind];

  @override
  bool? get stringify => true;
}

class MindSyncronizationStarted extends MindState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class MindSyncronizationComplete extends MindState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
