// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:keklist/helpers/mind_utils.dart';
import 'package:keklist/screens/main/main_screen.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:keklist/services/hive/constants.dart';
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
import 'package:workmanager/workmanager.dart';

import 'native/ios/watch/watch_communication_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupWidgets();
  _setupBlockingLoadingWidget();
  _setupOrientations();

  // Удаляет # в пути в начале для web приложений.
  setPathUrlStrategy();

  // Инициализация Hive.
  await _setupHive();

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
  final Injector injector = Injector();
  final Injector mainInjector = MainContainer().initialize(injector);

  // Подключаемся к Apple Watch.
  if (kIsWeb) {
    // no-op
  } else if (Platform.isIOS) {
    mainInjector.get<WatchCommunicationManager>().connect();
  }

  if (!kReleaseMode) {
    Bloc.observer = LoggerBlocObserver();
  }

  // Инициализация приложения.
  final Widget application = MultiBlocProvider(
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
  runApp(application);
}

// TODO: вынести в отдельный сервис или блок
// TODO: запрос только тех майндов, которые нужны с сервера.
@pragma('vm:entry-point')
void _updateTodayMindsInBackroundAndUpdateWidgets() {
  Workmanager().executeTask((task, inputData) async {
    print('widget updating started with $task');
    if (task == 'update-today-minds') {
      final MainService mainService = MainContainer().initialize(Injector()).get<MainService>();
      final List<Mind> todayMinds = (await mainService.getMindList())
          .where(
            (element) => element.rootId == null && element.dayIndex == MindUtils.getTodayIndex(),
          )
          .toList(growable: false);
      final List<String> todayMindJSONList = todayMinds
          .map(
            (mind) => json.encode(
              mind,
              toEncodable: (i) => mind.toShortJson(),
            ),
          )
          .toList();
      await HomeWidget.saveWidgetData(
        'mind_today_widget_today_minds',
        todayMindJSONList,
      );
      await HomeWidget.updateWidget(iOSName: PlatformConstants.iosMindDayWidgetName);
      print('widget success');
      return Future.value(true);
    } else {
      return Future.value(true);
    }
  });
}

void _setupWidgets() {
  HomeWidget.setAppGroupId(PlatformConstants.iosGroupId);
  Workmanager().initialize(
    _updateTodayMindsInBackroundAndUpdateWidgets,
    isInDebugMode: !kReleaseMode,
  );
  Workmanager().registerOneOffTask(
    'update-today-minds', // Shared task name.
    'updateTodayMinds', // Only Android supported.
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
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

Future<void> _setupHive() async {
  Hive.registerAdapter<SettingsObject>(SettingsObjectAdapter());
  Hive.registerAdapter<MindObject>(MindObjectAdapter());
  Hive.registerAdapter<QueueTransactionObject>(QueueTransactionObjectAdapter());
  await Hive.initFlutter();
  final Box<SettingsObject> settingsBox = await Hive.openBox<SettingsObject>(HiveConstants.settingsBoxName);
  // Открываем SettingBox и сохраняем дефолтные настройки.
  if (settingsBox.get(HiveConstants.settingsGlobalSettingsIndex) == null) {
    settingsBox.put(HiveConstants.settingsGlobalSettingsIndex, SettingsObject.initial());
  }
  // Открываем MindBox.
  await Hive.openBox<MindObject>(HiveConstants.mindBoxName);

  // Открываем MindQueueTransactionsBox.
  await Hive.openBox<QueueTransactionObject>(HiveConstants.mindQueueTransactionsBoxName);
}

void _setupOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class KeklistApp extends StatefulWidget {
  const KeklistApp({super.key});

  @override
  State<KeklistApp> createState() => KeklistAppState();
}

class KeklistAppState extends State<KeklistApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        title: 'Keklist',
        home: const MainScreen(),
        theme: ThemeData(
          primarySwatch: Palette.swatch,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: EasyLoading.init(),
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

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    print('onTransition: $bloc.state');
  }
}
