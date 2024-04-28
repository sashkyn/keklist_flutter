part of 'mind_creator_bloc.dart';

abstract class MindCreatorEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class MindCreatorChangeText extends MindCreatorEvent {
  final String text;

  MindCreatorChangeText({required this.text});

  @override
  List<Object?> get props => [text];
}
