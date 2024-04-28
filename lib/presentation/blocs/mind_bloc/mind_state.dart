part of 'mind_bloc.dart';

sealed class MindState {}

final class MindList extends MindState {
  final Iterable<Mind> values;

  MindList({required this.values});
}

final class MindMobileWidgetsUpdated extends MindState {}

final class MindSearching extends MindState {
  final bool enabled;
  final Iterable<Mind> allValues;
  final List<Mind> resultValues;

  MindSearching({
    required this.enabled,
    required this.allValues,
    required this.resultValues,
  });
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

final class MindOperationError extends MindState with EquatableMixin {
  final Iterable<Mind> minds;
  final MindOperationType notCompleted;

  MindOperationError({
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
        return 'The mind was not created';
      case MindOperationType.edit:
        return 'The mind was not edited';
      case MindOperationType.delete:
        return 'The mind was not deleted';
      case MindOperationType.deleteAll:
        return 'Minds were not deleted';
      case MindOperationType.fetch:
        return 'Minds were not fetched';
      case MindOperationType.uploadCachedData:
        return 'Minds were not upload';
      case MindOperationType.clearCache:
        return 'Could not clear cache';
    }
  }
}

final class MindServerOperationStarted extends MindState with EquatableMixin {
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

final class MindCandidatesForUpload extends MindState with EquatableMixin {
  final Iterable<Mind> values;

  MindCandidatesForUpload({required this.values});

  @override
  List<Object?> get props => [values];
}
