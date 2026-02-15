import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';

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
  final CubitStates notificationStatus;
  final String? actionSuccess; // Key or message
  final String? actionError; // Key or message
  final bool isActionKey; // If true, View should translate the message

  const SettingsLoaded({
    required this.settings,
    this.isNotificationEnabled = false,
    this.notificationStatus = CubitStates.initial,
    this.actionSuccess,
    this.actionError,
    this.isActionKey = false,
  });

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    bool? isNotificationEnabled,
    CubitStates? notificationStatus,
    String? actionSuccess,
    String? actionError,
    bool? isActionKey,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      actionSuccess: actionSuccess, // Intentionally not keeping previous
      actionError: actionError, // Intentionally not keeping previous
      isActionKey: isActionKey ?? false,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isNotificationEnabled,
    notificationStatus,
    actionSuccess,
    actionError,
    isActionKey,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
