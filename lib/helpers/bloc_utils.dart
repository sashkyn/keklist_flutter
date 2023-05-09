import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rememoji/helpers/extensions/state_extensions.dart';

// TODO: сделать Of как в Navigator
// TODO: обойти проблему, чтобы нельзя было вызвать sendToBloc(...) без указания типа B

class BlocUtils {
  static void sendEventTo<B extends Bloc>({
    required BuildContext? context,
    required Object event,
  }) {
    context?.read<B>().add(event);
  }
}

extension Heh on State {
  void sendEventTo<B extends Bloc>(Object event) {
    BlocUtils.sendEventTo<B>(context: mountedContext, event: event);
  }
}
