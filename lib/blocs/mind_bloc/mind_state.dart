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
  deleteAll,
  fetch,
  uploadCachedData,
  clearCache,
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

  String get localizedString {
    switch (notCompleted) {
      case MindOperationType.create:
        return 'Mind was not created';
      case MindOperationType.edit:
        return 'Mind was not edited';
      case MindOperationType.delete:
        return 'Mind was not deleted';
      case MindOperationType.deleteAll:
        return 'Minds were not deleted';
      case MindOperationType.fetch:
        return 'Minds were not fetched';
      case MindOperationType.uploadCachedData:
        return 'Mind were not upload';
      case MindOperationType.clearCache:
        return 'Could not clear cache';
    }
  }
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
