import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/settings_repository/object/settings_object.dart';
import 'package:keklist/domain/repositories/settings_repository/settings_repository.dart';
import 'package:rxdart/rxdart.dart';

final class SettingsHiveRepository implements SettingsRepository {
  final Box<SettingsObject> _hiveBox;
  final BehaviorSubject<KeklistSettings> _behaviorSubject = BehaviorSubject<KeklistSettings>();
  SettingsObject? get _settingsObject => _hiveBox.values.firstOrNull;

  SettingsHiveRepository({required Box<SettingsObject> box}) : _hiveBox = box {
    if (_settingsObject != null) {
      _behaviorSubject.add(_settingsObject!.toSettings());
    } else {
      updateSettings(KeklistSettings.initial());
    }
    _behaviorSubject.addStream(
      _hiveBox
          .watch()
          .where((_) => _settingsObject?.toSettings() != null)
          .map((_) => _settingsObject!.toSettings())
          .debounceTime(const Duration(milliseconds: 100)),
    );
  }

  @override
  KeklistSettings get value => _behaviorSubject.value;

  @override
  Stream<KeklistSettings> get stream => _behaviorSubject;

  @override
  FutureOr<void> updateDarkMode(bool isDarkMode) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isDarkMode = isDarkMode;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateMindContentVisibility(bool isVisible) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isMindContentVisible = isVisible;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateOfflineMode(bool isOfflineMode) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.isOfflineMode = isOfflineMode;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateOpenAIKey(String? openAIKey) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.openAIKey = openAIKey;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updatePreviousAppVersion(String? previousAppVersion) async {
    final SettingsObject? settingsObject = _hiveBox.get(HiveConstants.settingsGlobalSettingsIndex);
    settingsObject?.previousAppVersion = previousAppVersion;
    await settingsObject?.save();
  }

  @override
  FutureOr<void> updateSettings(KeklistSettings settings) async {
    await _hiveBox.put(HiveConstants.settingsGlobalSettingsIndex, settings.toObject());
  }
}
