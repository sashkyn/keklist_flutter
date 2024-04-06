import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:hive/hive.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/auth/auth_minotaur.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/mind/mind_hive_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:keklist/domain/repositories/settings/settings_hive_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/mind_service/main_supabase_service.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keklist/presentation/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:keklist/presentation/native/ios/watch/watch_communication_manager.dart';
import 'package:keklist/domain/services/mind_service/main_service.dart';

final class MainContainer {
  Injector initialize(Injector injector) {
    injector.map<MindService>(
      (injector) => MindSupabaseService(),
      isSingleton: true,
    );
    injector.map<MindSearcherCubit>(
      (injector) => MindSearcherCubit(repository: injector.get<MindRepository>()),
    );
    if (DeviceUtils.safeGetPlatform() == SupportedPlatform.iOS) {
      injector.map<WatchCommunicationManager>(
        (injector) => (AppleWatchCommunicationManager(
          mainService: injector.get<MindService>(),
          client: Supabase.instance.client,
        )),
        isSingleton: true,
      );
    }
    injector.map<MindRepository>(
      (injector) => MindHiveRepository(box: Hive.box<MindObject>(HiveConstants.mindBoxName)),
    );
    injector.map<SettingsRepository>(
      (injector) => SettingsHiveRepository(box: Hive.box<SettingsObject>(HiveConstants.settingsBoxName)),
    );
    injector.map<AuthMinotaur>(
      (injector) => AuthSupabaseMinotaur(client: Supabase.instance.client),
    );
    return injector;
  }
}
