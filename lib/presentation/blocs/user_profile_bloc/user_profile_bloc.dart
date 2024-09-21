import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:uuid/uuid.dart';

final class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final MindRepository _mindRepository;

  UserProfileBloc({
    required MindRepository mindRepository,
  })  : _mindRepository = mindRepository,
        super(
          UserProfileState(
            userName: '',
            userDescribingMinds: [],
            userDescribingSuggestionEmojies: [],
          ),
        ) {
    on<UserProfileGet>(_getUserProfile);
    on<UserProfileAddDescribingMind>(_addDescribingMind);
  }

  // On-Events

  Future<void> _getUserProfile(UserProfileGet event, Emitter<UserProfileState> emit) async {
    final List<Mind> userDescribingMinds = (await _mindRepository.obtainMindsWhere((mind) {
      return mind.dayIndex == 0; // TODO: change it to birhday of user
    }))
        .toList(growable: false);
    final List<String> suggestionEmojies = (await _getSuggestionEmojies())
        .where((suggestionEmoji) => !userDescribingMinds.map((mind) => mind.emoji).contains(suggestionEmoji))
        .toList()
        .distinct();
    emit(
      UserProfileState(
        userName: "@sashkyn", // TODO: store it
        userDescribingMinds: userDescribingMinds,
        userDescribingSuggestionEmojies: suggestionEmojies,
      ),
    );
  }

  Future<void> _addDescribingMind(
    UserProfileAddDescribingMind event,
    Emitter<UserProfileState> emit,
  ) async {
    final Mind mind = await _mindRepository.createMind(
      mind: Mind(
        id: const Uuid().v4(),
        dayIndex: 0,
        note: event.note,
        emoji: event.emoji,
        creationDate: DateTime.now().toUtc(),
        sortIndex: 0,
        rootId: null,
      ),
      isUploadedToServer: false,
    );
    final List<String> newSuggestions = state.userDescribingSuggestionEmojies
        .where((suggestionEmoji) => suggestionEmoji != event.emoji)
        .toList(growable: false);
    emit(
      UserProfileState(
        userName: state.userName,
        userDescribingMinds: state.userDescribingMinds.concat([mind]),
        userDescribingSuggestionEmojies: newSuggestions,
      ),
    );
  }

  // Private functions

  Future<List<String>> _getSuggestionEmojies() async {
    final Iterable<Mind> minds = await _mindRepository.obtainMinds();
    final List<String> predictedEmojies = minds
        .map((mind) => mind.emoji)
        .toList()
        .distinct()
        .sorted((emoji1, emoji2) => minds
            .where((mind) => mind.emoji == emoji2)
            .length
            .compareTo(minds.where((mind) => mind.emoji == emoji1).length))
        .toList(growable: false);
    return predictedEmojies;
  }
}

// Events.

abstract class UserProfileEvent {}

final class UserProfileGet extends UserProfileEvent {
  UserProfileGet();
}

final class UserProfileAddDescribingMind extends UserProfileEvent {
  final String emoji;
  final String note;

  UserProfileAddDescribingMind({required this.emoji, required this.note});
}

// State.

final class UserProfileState {
  final String userName;
  final List<Mind> userDescribingMinds;
  final List<String> userDescribingSuggestionEmojies;

  UserProfileState({
    required this.userName,
    required this.userDescribingMinds,
    required this.userDescribingSuggestionEmojies,
  });
}
