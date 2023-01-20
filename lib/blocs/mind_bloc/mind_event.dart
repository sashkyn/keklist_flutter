part of 'mind_bloc.dart';

@immutable
abstract class MindEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MindGetMinds extends MindEvent {}

class MindCreate extends MindEvent {
  final int dayIndex;
  final String note;
  final String emoji;

  MindCreate({
    required this.dayIndex,
    required this.note,
    required this.emoji,
  });

  @override
  List<Object?> get props => [dayIndex, note, emoji];
}

class MindDelete extends MindEvent {
  final String uuid;

  MindDelete({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

class MindEdit extends MindEvent {}

class MindMove extends MindEvent {}

class MindCopyToNow extends MindEvent {}

class MindStartSearch extends MindEvent {}

class MindEnterSearchText extends MindEvent {
  final String text;

  MindEnterSearchText({required this.text});

  @override
  List<Object?> get props => [text];
}

class MindStopSearch extends MindEvent {}

class MindChangeCreateText extends MindEvent {
  final String text;

  MindChangeCreateText({required this.text});

  @override
  List<Object?> get props => [text];
}

class MindResetStorage extends MindEvent {}
