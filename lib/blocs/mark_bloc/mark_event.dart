part of 'mark_bloc.dart';

// TODO: Factory initialization

@immutable
abstract class MarkEvent {}

class ConnectToLocalStorageMarkEvent extends MarkEvent {}

class StartListenSyncedUserMarkEvent extends MarkEvent {}

class ObtainMarksFromLocalStorageMarkEvent extends MarkEvent {}

class ObtainMarksFromCloudStorageMarkEvent extends MarkEvent {}

class CreateMarkEvent extends MarkEvent {}

class DeleteMarkEvent extends MarkEvent {}

class EditMarkEvent extends MarkEvent {}

class MoveMarkEvent extends MarkEvent {}

class CopyMarkEvent extends MarkEvent {}