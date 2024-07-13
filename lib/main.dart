// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:keklist/domain/services/auth/auth_service.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/keklist_app.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/message/message/message_object.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:keklist/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:keklist/di/containers.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';

import 'presentation/native/ios/watch/watch_communication_manager.dart';

// TODO: fix or exclude home_widget for android only

final class PrivacySettings {
  static final PrivacySettings _instance = PrivacySettings();

  bool isTextHidden = false;

  factory PrivacySettings() => _instance;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initNativeWidgets();
  _setupBlockingLoadingWidget();

  await dotenv.load(fileName: '.env');
  setPathUrlStrategy();
  await _initHive();
  await _initSupabase();

  // Инициализация DI-контейнера.
  final Injector injector = Injector();
  final Injector mainInjector = MainContainer().initialize(injector);

  _connectToWatchCommunicationManager(mainInjector);
  _enableDebugBLOCLogs();
  _configureOpenAI();

  final Widget application = _getApplication(mainInjector);
  runApp(application);
}

void _configureOpenAI() {
  OpenAI.showLogs = !kReleaseMode;
  OpenAI.requestsTimeOut = const Duration(seconds: 40);
}

Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
    debug: !kReleaseMode,
  );
}

void _enableDebugBLOCLogs() {
  if (!kReleaseMode) {
    Bloc.observer = _LoggerBlocObserver();
  }
}

void _connectToWatchCommunicationManager(Injector mainInjector) {
  if (kIsWeb) {
    // no-op
  } else if (Platform.isIOS) {
    mainInjector.get<WatchCommunicationManager>().connect();
  }
}

Widget _getApplication(Injector mainInjector) => MultiProvider(
      providers: [
        RepositoryProvider(create: (context) => mainInjector.get<MindRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MindBloc(
              mainService: mainInjector.get<MindService>(),
              mindSearcherCubit: mainInjector.get<MindSearcherCubit>(),
              mindRepository: mainInjector.get<MindRepository>(),
              settingsRepository: mainInjector.get<SettingsRepository>(),
            ),
          ),
          BlocProvider(create: (context) => mainInjector.get<MindSearcherCubit>()),
          BlocProvider(
            create: (context) => AuthBloc(
              mainService: mainInjector.get<MindService>(),
              authRepository: mainInjector.get<AuthService>(),
            ),
          ),
          BlocProvider(
            create: (context) => SettingsBloc(
              repository: mainInjector.get<SettingsRepository>(),
              authService: mainInjector.get<AuthService>(),
              mindRepository: mainInjector.get<MindRepository>(),
              mindService: mainInjector.get<MindService>(),
            ),
          ),
        ],
        child: const KeklistApp(),
      ),
    );

void _initNativeWidgets() {
  //HomeWidget.setAppGroupId(PlatformConstants.iosGroupId);
}

void _setupBlockingLoadingWidget() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 10000)
    ..indicatorType = EasyLoadingIndicatorType.doubleBounce
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withAlpha(200)
    ..indicatorColor = Colors.white
    ..textColor = Colors.black
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

Future<void> _initHive() async {
  Hive.registerAdapter<SettingsObject>(SettingsObjectAdapter());
  Hive.registerAdapter<MindObject>(MindObjectAdapter());
  Hive.registerAdapter<MessageObject>(MessageObjectAdapter());
  await Hive.initFlutter();
  final Box<SettingsObject> settingsBox = await Hive.openBox<SettingsObject>(HiveConstants.settingsBoxName);
  if (settingsBox.get(HiveConstants.settingsGlobalSettingsIndex) == null) {
    settingsBox.put(HiveConstants.settingsGlobalSettingsIndex, KeklistSettings.initial().toObject());
  }
  await Hive.openBox<MindObject>(HiveConstants.mindBoxName);
  await Hive.openBox<MessageObject>(HiveConstants.messageChatBoxName);
}

final class _LoggerBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    if (kDebugMode) {
      print('onEvent: $event');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    if (kDebugMode) {
      print(error);
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    if (kDebugMode) {
      print('onChange: ${bloc.state}');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);

    if (kDebugMode) {
      print('onClose: ${bloc.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (kDebugMode) {
      print('onTransition: $bloc.state');
    }
  }
}
