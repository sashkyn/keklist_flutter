part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsGet extends SettingsEvent {}

class SettingsExportAllMindsToCSV extends SettingsEvent {}

class SettingsChangeMindContentVisibility extends SettingsEvent {
  final bool isVisible;

  const SettingsChangeMindContentVisibility({required this.isVisible});
}

class SettingsWhatsNewShown extends SettingsEvent {}
