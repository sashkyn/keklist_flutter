// ignore_for_file: avoid_print

import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';
import 'package:zenmode/blocs/mark_bloc/mark_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenmode/cubits/mark_searcher/mark_searcher_cubit.dart';
import 'package:zenmode/di/containers.dart';
import 'package:zenmode/storages/storage.dart';

import 'screens/mark_collection/mark_collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  // Инициализация настроек Supabase.
  await Supabase.initialize(
    url: 'https://vocsvvwlghhgmphrggre.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvY3N2dndsZ2hoZ21waHJnZ3JlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjU5MzkwNzksImV4cCI6MTk4MTUxNTA3OX0.9wBizohsoXYmiqitoiHQPrLCc7-uVvF-FTu-DyXlfWc',
    authCallbackUrlHostname: 'login-callback',
    debug: !kReleaseMode,
    storageRetryAttempts: 5,
  );

  // Инициализация DI-контейнера.
  final mainContainer = MainContainer().initialise(Injector());

  if (!kReleaseMode) {
    Bloc.observer = LoggerBlocObserver();
  }

  // Инициализация приложения.
  final Widget application = MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => MarkBloc(
          storage: mainContainer.get<IStorage>(),
          searcherCubit: mainContainer.get<MarkSearcherCubit>(),
        ),
      ),
      BlocProvider(create: (context) => mainContainer.get<MarkSearcherCubit>()),
      BlocProvider(create: (context) => AuthBloc()),
    ],
    child: ZenmodeApp(app: app),
  );
  runApp(application);
}

class ZenmodeApp extends StatefulWidget {
  final FirebaseApp app;

  const ZenmodeApp({Key? key, required this.app}) : super(key: key);

  @override
  State<ZenmodeApp> createState() => ZenmodeAppState();
}

class ZenmodeAppState extends State<ZenmodeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenmode',
      home: const MarkCollectionScreen(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
