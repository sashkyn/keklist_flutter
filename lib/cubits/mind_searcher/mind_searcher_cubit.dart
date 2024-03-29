import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/services/main_service.dart';

part 'mind_searcher_state.dart';

class MindSearcherCubit extends Cubit<MindSearcherState> {
  late final MainService service;

  MindSearcherCubit({required MainService mainService}) : super(MindSearcherInitial()) {
    service = mainService;
  }

  final _emojiParser = EmojiParser();

  Future<List<Mind>> searchMindList(String text) async {
    final lowerCasedTrimmedText = text.toLowerCase().trim();

    final minds = await service.getMindList();
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
