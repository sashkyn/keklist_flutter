import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rememoji/helpers/extensions/state_extensions.dart';

// TODO: сделать Of как в Navigator
// TODO: обойти проблему, чтобы нельзя было вызвать sendToBloc(...) без указания типа B

class BlocUtils {
  static StreamSubscription<dynamic>? subscribeTo<B extends Bloc>({
    required BuildContext context,
    required Function(dynamic) onState,
  }) {
    return context.read<B>().stream.listen(onState);
  }

  static void sendEventTo<B extends Bloc>({
    required BuildContext? context,
    required Object event,
  }) {
    context?.read<B>().add(event);
  }
}

extension SendEventFromState on State {
  void sendEventTo<B extends Bloc>(Object event) {
    BlocUtils.sendEventTo<B>(
      context: mountedContext,
      event: event,
    );
  }

  StreamSubscription<dynamic>? subscribeTo<B extends Bloc>({required Function(dynamic) onNewState}) {
    if (mountedContext == null) {
      return null;
    }
    return BlocUtils.subscribeTo<B>(
      context: mountedContext!,
      onState: onNewState,
    );
  }
}
