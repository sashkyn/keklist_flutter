import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/services/main_service.dart';

part 'mind_searcher_state.dart';

class MindSearcherCubit extends Cubit<MindSearcherState> {
  late final MainService _storage;

  MindSearcherCubit({required MainService mainService}) : super(MindSearcherInitial()) {
    _storage = mainService;
  }

  final _emojiParser = EmojiParser();

  Future<List<Mind>> searchMarkList(String text) async {
    final lowerCasedTrimmedText = text.toLowerCase().trim();

    final marks = await _storage.getMindList();
    final filteredMarks = marks.where((mark) {
      // Note condition.
      final noteCondition = mark.note.trim().toLowerCase().contains(
            lowerCasedTrimmedText,
          );

      // Emoji condition.
      final emojies = _emojiParser.parseEmojis(lowerCasedTrimmedText);
      final emojiCondintion = emojies.any((emoji) => mark.emoji == emoji);

      return noteCondition || emojiCondintion;
    }).toList();

    return filteredMarks;
  }
}
