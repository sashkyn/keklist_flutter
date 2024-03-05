import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ActionModel with EquatableMixin {
  final int id;
  final String title;
  final Icon icon;

  const ActionModel({
    required this.id,
    required this.title,
    required this.icon,
  });

  factory ActionModel.chatWithAI() => const ChatWithAIActionModel();
  factory ActionModel.photosPerDay() => const PhotosPerDayActionModel();
  factory ActionModel.extraActionsMenu() => const ExtraActionsMenuActionModel();

  @override
  List<Object?> get props => [id];
}

final class ChatWithAIActionModel extends ActionModel {
  const ChatWithAIActionModel()
      : super(
          id: 1,
          title: 'Chat with AI',
          icon: const Icon(Icons.chat),
        );
}

final class PhotosPerDayActionModel extends ActionModel {
  const PhotosPerDayActionModel()
      : super(
          id: 2,
          title: 'Photos per day',
          icon: const Icon(Icons.photo),
        );
}

final class ExtraActionsMenuActionModel extends ActionModel {
  const ExtraActionsMenuActionModel()
      : super(
          id: 3,
          title: 'Extra actions',
          icon: const Icon(Icons.read_more),
        );
}
