part of 'mark_bloc.dart';

@immutable
abstract class MarkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectToLocalStorageMarkEvent extends MarkEvent {}

class StartListenSyncedUserMarkEvent extends MarkEvent {}

class UserChangedMarkEvent extends MarkEvent {
  final User? user;

  @override
  List<Object?> get props => [user];

  UserChangedMarkEvent({this.user});
}

class GetMarksFromLocalStorageMarkEvent extends MarkEvent {}

class GetMarksFromCloudStorageMarkEvent extends MarkEvent {}

class CreateMarkEvent extends MarkEvent {
  final int dayIndex;
  final String note;
  final String emoji;

  CreateMarkEvent({
    required this.dayIndex,
    required this.note,
    required this.emoji,
  });

  @override
  List<Object?> get props => [dayIndex, note, emoji];
}

class DeleteMarkEvent extends MarkEvent {
  final String uuid;

  DeleteMarkEvent({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

class EditMarkEvent extends MarkEvent {}

class MoveMarkEvent extends MarkEvent {}

class CopyToNowMarkEvent extends MarkEvent {}

class StartSearchMarkEvent extends MarkEvent {}

class EnterTextSearchMarkEvent extends MarkEvent {
  final String text;

  EnterTextSearchMarkEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

class StopSearchMarkEvent extends MarkEvent {}

class ChangeTextOfCreatingMarkEvent extends MarkEvent {
  final String text;

  ChangeTextOfCreatingMarkEvent({required this.text});

  @override
  List<Object?> get props => [text];
}
