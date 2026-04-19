import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<SettingItemModel> settings;
  final bool isNotificationEnabled;
  final bool isSoundEnabled;
  final CubitStates notificationStatus;
  final String? actionSuccess; // Key or message
  final String? actionError; // Key or message
  final bool isActionKey; // If true, View should translate the message
  final int actionTimestamp;
  final int points;
  final String referralLink;

  const SettingsLoaded({
    required this.settings,
    this.isNotificationEnabled = false,
    this.isSoundEnabled = false,
    this.notificationStatus = CubitStates.initial,
    this.actionSuccess,
    this.actionError,
    this.isActionKey = false,
    this.actionTimestamp = 0,
    this.points = 0,
    this.referralLink = '',
  });

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    bool? isNotificationEnabled,
    bool? isSoundEnabled,
    CubitStates? notificationStatus,
    String? actionSuccess,
    String? actionError,
    bool? isActionKey,
    int? actionTimestamp,
    int? points,
    String? referralLink,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      actionSuccess: actionSuccess, // Intentionally not keeping previous
      actionError: actionError, // Intentionally not keeping previous
      isActionKey: isActionKey ?? false,
      actionTimestamp: actionTimestamp ?? this.actionTimestamp,
      points: points ?? this.points,
      referralLink: referralLink ?? this.referralLink,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isNotificationEnabled,
    isSoundEnabled,
    notificationStatus,
    actionSuccess,
    actionError,
    isActionKey,
    actionTimestamp,
    points,
    referralLink,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
