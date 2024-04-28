import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';

part 'mind_searcher_state.dart';

final class MindSearcherCubit extends Cubit<MindSearcherState> {
  final MindRepository repository;

  MindSearcherCubit({required this.repository}) : super(MindSearcherInitial());

  final _emojiParser = EmojiParser();

  Future<List<Mind>> searchMindList(String text) async {
    final lowerCasedTrimmedText = text.toLowerCase().trim();

    final minds = repository.values;
    final filteredMinds = minds.where((mind) {
      // Note condition.
      final noteCondition = mind.note.trim().toLowerCase().contains(lowerCasedTrimmedText);

      // Emoji condition.
      final emojies = _emojiParser.parseEmojis(lowerCasedTrimmedText);
      final emojiCondition = emojies.any((emoji) => mind.emoji == emoji);

      return noteCondition || emojiCondition;
    }).toList();

    return filteredMinds;
  }
}
