import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class SettingsInitial extends UserProfileState {}

class SettingsLoading extends UserProfileState {}

class SettingsLoaded extends UserProfileState {
  final List<SettingItemModel> settings;
  final UserProfileModel? userProfile;

  const SettingsLoaded({required this.settings, this.userProfile});

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    UserProfileModel? userProfile,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

class SettingsError extends UserProfileState {
  final String message;

  const SettingsError({required this.message});
}
