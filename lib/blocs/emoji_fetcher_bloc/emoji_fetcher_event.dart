part of 'emoji_fetcher_bloc.dart';

@immutable
abstract class EmojiFetcherEvent {}

class SearchEmojiFetcherEvent extends EmojiFetcherEvent {
  final String searchtext;

  SearchEmojiFetcherEvent(this.searchtext);
}