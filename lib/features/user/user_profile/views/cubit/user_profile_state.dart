import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends UserProfileState {}

class SettingsLoading extends UserProfileState {}

class SettingsLoaded extends UserProfileState {
  final List<SettingItemModel> settings;
  final UserProfileModel? userProfile;
  final bool isNotificationEnabled;

  const SettingsLoaded({
    required this.settings,
    this.userProfile,
    this.isNotificationEnabled = false,
  });

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    UserProfileModel? userProfile,
    bool? isNotificationEnabled,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      userProfile: userProfile ?? this.userProfile,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }

  @override
  List<Object?> get props => [settings, userProfile, isNotificationEnabled];
}

class SettingsError extends UserProfileState {
  final String message;

  const SettingsError({required this.message});
}
