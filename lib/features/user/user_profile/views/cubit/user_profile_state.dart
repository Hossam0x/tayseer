import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class SettingsInitial extends UserProfileState {}

class SettingsLoading extends UserProfileState {}

class SettingsLoaded extends UserProfileState {
  final List<SettingItemModel> settings;

  const SettingsLoaded({required this.settings});
}

class SettingsError extends UserProfileState {
  final String message;

  const SettingsError({required this.message});
}
