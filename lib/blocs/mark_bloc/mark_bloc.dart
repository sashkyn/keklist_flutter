import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'mark_event.dart';
part 'mark_state.dart';

class MarkBloc extends Bloc<MarkEvent, MarkState> {
  MarkBloc() : super(MarkInitial()) {
    on<MarkEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
