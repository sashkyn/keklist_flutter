import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:rxdart/rxdart.dart';
import 'package:emojis/emoji.dart' as emojies_pub;

part 'mind_creator_event.dart';
part 'mind_creator_state.dart';

final class MindCreatorBloc extends Bloc<MindCreatorEvent, MindCreatorState> {
  final MindRepository mindRepository;

  MindCreatorBloc({
    required this.mindRepository,
  }) : super(MindCreatorState(suggestions: [])) {
    on<MindCreatorEvent>((event, emit) {});
    on<MindCreatorChangeText>(
      _getSuggestions,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 200)).asyncExpand(mapper),
    );
  }

  FutureOr<void> _getSuggestions(
    MindCreatorChangeText event,
    Emitter<MindCreatorState> emit,
  ) async {
    final Iterable<Mind> minds = List.of(mindRepository.values, growable: false);
    final Iterable<String> suggestions = await Isolate.run(() {
      const count = 9;
      final Iterable<String> suggestions = minds
          .where((Mind mind) => mind.note.trim().toLowerCase().contains(event.text.trim().toLowerCase()))
          .map((Mind mind) => mind.emoji)
          .toList()
          .distinct()
          .sorted((String emoji1, String emoji2) => minds
              .where((Mind mind) => mind.emoji == emoji2)
              .length
              .compareTo(minds.where((mind) => mind.emoji == emoji1).length))
          .take(9);

      if (suggestions.isEmpty) {
        if (minds.isEmpty) {
          return emojies_pub.Emoji.all().take(count).map((emoji) => emoji.char);
        } else {
          return suggestions;
        }
      } else {
        return suggestions;
      }
    });
    emit(MindCreatorState(suggestions: suggestions));
  }
}
