import 'package:bloc/bloc.dart';
import 'package:emojis/emoji.dart';
import 'package:meta/meta.dart';

part 'emoji_fetcher_event.dart';
part 'emoji_fetcher_state.dart';

class EmojiFetcherBloc extends Bloc<EmojiFetcherEvent, EmojiFetcherState> {
  final List<Emoji> _emojiList = Emoji.all();

  EmojiFetcherBloc(EmojiFetcherState initialState)
      : super(EmojiFetcherState('', Emoji.all().map((emoji) => emoji.char).toList())) {
    on<SearchEmojiFetcherEvent>((event, emit) {
      emit(
        EmojiFetcherState(
          event.searchtext,
          _emojiList
              .where((emoji) => emoji.keywords.join().contains(event.searchtext.toLowerCase().trim()))
              .map((emoji) => emoji.char)
              .toList(),
        ),
      );
    });
  }
}
