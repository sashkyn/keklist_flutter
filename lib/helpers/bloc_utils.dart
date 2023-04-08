import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: сделать Of как в Navigator
// TODO: обойти проблему, чтобы нельзя было вызвать sendToBloc(...) без указания типа B

class BlocUtils {
  static void sendTo<B extends Bloc>({
    required BuildContext? context,
    required Object event,
  }) {
    context?.read<B>().add(event);
  }
}
