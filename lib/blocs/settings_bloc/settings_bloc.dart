import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rememoji/services/main_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MainService mainService;

  SettingsBloc({required this.mainService})
      : super(const SettingsState(
          isMindContentVisible: false,
        )) {
    on<SettingsExportAllMindsToCSV>(_shareCSVFileWithMinds);
    on<SettingsChangeMindContentVisibility>(_changeMindContentVisibility);
    on<SettingsGet>(_getSettings);
  }

  FutureOr<void> _changeMindContentVisibility(
    SettingsChangeMindContentVisibility event,
    Emitter<SettingsState> emit,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_mind_content_visible', event.isVisible);
    emit(
      SettingsState(
        isMindContentVisible: event.isVisible,
      ),
    );
  }

  FutureOr<void> _shareCSVFileWithMinds(event, emit) async {
    // Получение minds.
    final minds = await mainService.getMindList();
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = minds.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter().convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File csvFile = File('${temporaryDirectory.path}/user_data.csv'); // TODO: добавить дату в название файла.
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }

  FutureOr<void> _getSettings(SettingsGet event, Emitter<SettingsState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isMindContentVisible = prefs.getBool('settings_mind_content_visible') ?? false;
    emit(
      SettingsState(
        isMindContentVisible: isMindContentVisible,
      ),
    );
  }
}
