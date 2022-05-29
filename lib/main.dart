// ignore_for_file: avoid_print

import 'package:emodzen/blocs/mark_bloc/mark_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/mark_collection/mark_collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  BlocOverrides.runZoned(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MarkBloc()),
        ],
        child: KeklistApp(app: app),
      ),
    ),
    blocObserver: MyBlocObserver(),
  );
}

class KeklistApp extends StatefulWidget {
  final FirebaseApp app;

  const KeklistApp({Key? key, required this.app}) : super(key: key);

  @override
  State<KeklistApp> createState() => _KeklistAppState();
}

class _KeklistAppState extends State<KeklistApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emodzen',
      debugShowCheckedModeBanner: false,
      home: const MarkCollectionScreen(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class MyBlocObserver extends BlocObserver {
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
