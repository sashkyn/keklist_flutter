import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:zenmode/cubits/mark_searcher/mark_searcher_cubit.dart';
import 'package:zenmode/storages/storage.dart';
import 'package:zenmode/storages/supabase_storage.dart';

class MainContainer {
  Injector initialise(Injector injector) {
    injector.map<IStorage>((injector) => SupabaseStorage(), isSingleton: true);
    injector.map<MarkSearcherCubit>((injector) => MarkSearcherCubit(storage: injector.get<IStorage>()));
    return injector;
  }
}
