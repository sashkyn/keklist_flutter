import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:zenmode/cubits/mind_searcher/mind_searcher_cubit.dart';
import 'package:zenmode/services/main_service.dart';
import 'package:zenmode/services/main_supabase_service.dart';

class MainContainer {
  Injector initialize(Injector injector) {
    injector.map<MainService>(
      (injector) => MainSupabaseService(),
      isSingleton: true,
    );
    injector.map<MindSearcherCubit>((injector) => MindSearcherCubit(mainService: injector.get<MainService>()));
    return injector;
  }
}
