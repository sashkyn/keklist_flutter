// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:keklist/blocs/message_bloc/message_bloc.dart';
import 'package:keklist/keklist_app.dart';
import 'package:keklist/services/hive/constants.dart';
import 'package:keklist/services/hive/entities/message/message_object.dart';
import 'package:keklist/services/hive/entities/mind/mind_object.dart';
import 'package:keklist/services/hive/entities/queue_transaction/queue_transaction_object.dart';
import 'package:keklist/services/hive/entities/settings/settings_object.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:keklist/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/constants.dart';
import 'package:keklist/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:keklist/di/containers.dart';
import 'package:keklist/services/main_service.dart';

import 'native/ios/watch/watch_communication_manager.dart';

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
  _enableBlocLogs();
  final Widget application = _getApplication(mainInjector);
  runApp(application);
}

Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
    debug: !kReleaseMode,
  );
}

void _enableBlocLogs() {
  if (!kReleaseMode) {
    Bloc.observer = LoggerBlocObserver();
  }
}

void _connectToWatchCommunicationManager(Injector mainInjector) {
  if (kIsWeb) {
    // no-op
  } else if (Platform.isIOS) {
    mainInjector.get<WatchCommunicationManager>().connect();
  }
}

MultiBlocProvider _getApplication(Injector mainInjector) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MindBloc(
            mainService: mainInjector.get<MainService>(),
            mindSearcherCubit: mainInjector.get<MindSearcherCubit>(),
          ),
        ),
        BlocProvider(create: (context) => mainInjector.get<MindSearcherCubit>()),
        BlocProvider(
          create: (context) => AuthBloc(
            mainService: mainInjector.get<MainService>(),
            client: Supabase.instance.client,
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            mainService: mainInjector.get<MainService>(),
            client: Supabase.instance.client,
          ),
        ),
      ],
      child: const KeklistApp(),
    );

void _initNativeWidgets() {
  HomeWidget.setAppGroupId(PlatformConstants.iosGroupId);
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
  Hive.registerAdapter<QueueTransactionObject>(QueueTransactionObjectAdapter());
  Hive.registerAdapter<MessageObject>(MessageObjectAdapter());
  await Hive.initFlutter();
  final Box<SettingsObject> settingsBox = await Hive.openBox<SettingsObject>(HiveConstants.settingsBoxName);
  if (settingsBox.get(HiveConstants.settingsGlobalSettingsIndex) == null) {
    settingsBox.put(HiveConstants.settingsGlobalSettingsIndex, SettingsObject.initial());
  }
  await Hive.openBox<MindObject>(HiveConstants.mindBoxName);
  await Hive.openBox<MessageObject>(HiveConstants.messageChatBoxName);
  // TODO: remove
  await Hive.openBox<QueueTransactionObject>(HiveConstants.mindQueueTransactionsBoxName);
}
