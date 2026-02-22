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
  final bool isMarriageSectionDeactivated; 
  final List<SettingItemModel> settings;
  final UserProfileModel? userProfile;
  final bool isNotificationEnabled;
  final String? actionMessage;
  final bool?
  isActionSuccess; // Simple boolean for success/failure of last action
  final int
  actionTimestamp; // To force listener to react even if message is same

  const SettingsLoaded({
    required this.settings,
    this.userProfile,
    this.isNotificationEnabled = false,
    this.actionMessage,
    this.isActionSuccess,
    this.actionTimestamp = 0,
    this.isMarriageSectionDeactivated = false
  });

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    UserProfileModel? userProfile,
    bool? isNotificationEnabled,
    bool? isMarriageSectionDeactivated,
    String? actionMessage,
    bool? isActionSuccess,
    int? actionTimestamp,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      userProfile: userProfile ?? this.userProfile,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      isMarriageSectionDeactivated: isMarriageSectionDeactivated ?? this.isMarriageSectionDeactivated,    
      actionMessage:
          actionMessage, // Not keeping previous message by default to avoid stale snacks
      isActionSuccess: isActionSuccess,
      actionTimestamp: actionTimestamp ?? this.actionTimestamp,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    userProfile,
    isMarriageSectionDeactivated,
    isNotificationEnabled,
    actionMessage,
    isActionSuccess,
    actionTimestamp,
  ];
}

class SettingsError extends UserProfileState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
