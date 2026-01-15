import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<SettingItemModel> settings;

  const SettingsLoaded({required this.settings});
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});
}
