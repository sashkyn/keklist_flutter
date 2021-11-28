part of 'emoji_fetcher_bloc.dart';

class EmojiFetcherState {
  final String searchText;
  final List<String> emojiList;

  EmojiFetcherState(
    this.searchText,
    this.emojiList,
  );
}