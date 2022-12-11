import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:zenmode/storages/entities/mark.dart';
import 'package:zenmode/storages/storage.dart';

part 'mark_searcher_state.dart';

class MarkSearcherCubit extends Cubit<MarkSearcherState> {
  late final IStorage _storage;

  MarkSearcherCubit({required IStorage storage}) : super(MarkSearcherInitial()) {
    _storage = storage;
  }

  final _emojiParser = EmojiParser();

  Future<List<Mark>> searchMarkList(String text) async {
    final lowerCasedTrimmedText = text.toLowerCase().trim();
    
    final marks = await _storage.getMarks();
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
