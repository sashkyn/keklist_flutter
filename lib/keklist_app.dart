import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/constants.dart';
import 'package:keklist/core/helpers/bloc_utils.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/screens/main/main_screen.dart';

class KeklistApp extends StatefulWidget {
  const KeklistApp({super.key});

  @override
  State<KeklistApp> createState() => KeklistAppState();
}

class KeklistAppState extends State<KeklistApp> with DisposeBag {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsDataState) {
        setState(() => _isDarkMode = state.isDarkMode);
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keklist',
      home: const MainScreen(),
      theme: _isDarkMode ? Themes.dark : Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeMode.light,
      builder: EasyLoading.init(),
    );
  }
}

class LoggerBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    print('onEvent: $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    print(error);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    print('onChange: ${bloc.state}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);

    print('onClose: ${bloc.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    print('onTransition: $bloc.state');
  }
}