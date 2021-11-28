part of 'mark_bloc.dart';

@immutable
abstract class MarkEvent {}

class CreateMarkEvent extends MarkEvent {}
class DeleteMarkEvent extends MarkEvent {}
class EditMarkEvent extends MarkEvent {}
class MoveMarkEvent extends MarkEvent {}
class CopyMarkEvent extends MarkEvent {}

