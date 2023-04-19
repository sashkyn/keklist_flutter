// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rememoji/blocs/mind_bloc/mind_bloc.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:rememoji/di/containers.dart';
import 'package:rememoji/services/main_service.dart';

import 'native/ios/watch/watch_communication_manager.dart';
import 'screens/mind_collection/mind_collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupOrientations();

  // Удаляет # в пути в начале для web приложений.
  setPathUrlStrategy();
  // Инициализация настроек Supabase.
  await Supabase.initialize(
    url: '***REMOVED***',
    anonKey:
        '***REMOVED***',
    authCallbackUrlHostname: 'login-callback',
    debug: !kReleaseMode,
    storageRetryAttempts: 5,
  );

  // Инициализация DI-контейнера.
  final injector = Injector();
  final mainContainer = MainContainer().initialize(injector);

  // Подключаемся к Apple Watch.
  if (Platform.isIOS) {
    mainContainer.get<WatchCommunicationManager>().connect();
  }

  if (!kReleaseMode) {
    Bloc.observer = LoggerBlocObserver();
  }

  // Инициализация приложения.
  final Widget application = MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => MindBloc(
          mainService: mainContainer.get<MainService>(),
          mindSearcherCubit: mainContainer.get<MindSearcherCubit>(),
        ),
      ),
      BlocProvider(create: (context) => mainContainer.get<MindSearcherCubit>()),
      BlocProvider(
        create: (context) => AuthBloc(
          mainService: mainContainer.get<MainService>(),
          client: Supabase.instance.client,
        ),
      ),
      BlocProvider(
        create: (context) => SettingsBloc(mainService: mainContainer.get<MainService>()),
      ),
    ],
    child: const KeklistApp(),
  );
  runApp(application);
}

void _setupOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class KeklistApp extends StatefulWidget {
  const KeklistApp({Key? key}) : super(key: key);

  @override
  State<KeklistApp> createState() => KeklistAppState();
}

class KeklistAppState extends State<KeklistApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        title: 'Rememoji',
        home: const MindCollectionScreen(),
        theme: ThemeData(
          primarySwatch: Palette.swatch,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
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

  // @override
  // void onTransition(Bloc bloc, Transition transition) {
  //   super.onTransition(bloc, transition);

  //   print('onTransition: $bloc.state');
  // }
}
