// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';
import 'package:zenmode/blocs/mark_bloc/mind_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenmode/blocs/settings_bloc/settings_bloc.dart';
import 'package:zenmode/cubits/mark_searcher/mark_searcher_cubit.dart';
import 'package:zenmode/di/containers.dart';
import 'package:zenmode/storages/storage.dart';

import 'screens/mark_collection/mark_collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final FirebaseApp app = await Firebase.initializeApp();

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
  final mainContainer = MainContainer().initialise(injector);

  if (!kReleaseMode) {
    Bloc.observer = LoggerBlocObserver();
  }

  // Инициализация приложения.
  final Widget application = MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => MindBloc(
          storage: mainContainer.get<IStorage>(),
          searcherCubit: mainContainer.get<MarkSearcherCubit>(),
        ),
      ),
      BlocProvider(create: (context) => mainContainer.get<MarkSearcherCubit>()),
      BlocProvider(create: (context) => AuthBloc()),
      BlocProvider(
        create: (context) => SettingsBloc(storage: mainContainer.get<IStorage>()),
      ),
    ],
    child: const ZenmodeApp(),
  );
  runApp(application);
}

class ZenmodeApp extends StatefulWidget {
  const ZenmodeApp({Key? key}) : super(key: key);

  @override
  State<ZenmodeApp> createState() => ZenmodeAppState();
}

class ZenmodeAppState extends State<ZenmodeApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        title: 'Zenmode',
        home: const MindCollectionScreen(),
        theme: ThemeData(
          primarySwatch: Colors.grey,
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
