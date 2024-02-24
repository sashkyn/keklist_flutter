import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:keklist/services/mind_service/main_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keklist/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:keklist/native/ios/watch/watch_communication_manager.dart';
import 'package:keklist/services/mind_service/main_service.dart';

class MainContainer {
  Injector initialize(Injector injector) {
    injector.map<MindService>(
      (injector) => MindSupabaseService(),
      isSingleton: true,
    );
    injector.map<MindSearcherCubit>(
      (injector) => MindSearcherCubit(mainService: injector.get<MindService>()),
    );
    if (kIsWeb) {
      // no-op
    } else if (Platform.isIOS) {
      injector.map<WatchCommunicationManager>(
        (injector) => (AppleWatchCommunicationManager(
          mainService: injector.get<MindService>(),
          client: Supabase.instance.client,
        )),
        isSingleton: true,
      );
    }
    return injector;
  }
}
