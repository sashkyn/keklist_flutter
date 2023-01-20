import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zenmode/services/main_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MainService mainService;

  SettingsBloc({required this.mainService}) : super(const SettingsState()) {
    on<ExportMarksToCSVSettingsEvent>(_shareCSVFileWithMarks);
  }

  FutureOr<void> _shareCSVFileWithMarks(event, emit) async {
    // Получение minds.
    final marks = await mainService.getMindList();
    // Конвертация в CSV и шаринг.
    final List<List<String>> csvEntryList = marks.map((entry) => entry.toCSVEntry()).toList(growable: false);
    final String csv = const ListToCsvConverter().convert(csvEntryList);
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File csvFile = File('${temporaryDirectory.path}/user_data.csv');
    await csvFile.writeAsString(csv);
    final XFile fileToShare = XFile(csvFile.path);
    await Share.shareXFiles([fileToShare]);
  }
}
