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

  const SettingsLoaded({
    required this.settings,
    this.isNotificationEnabled = false,
    this.notificationStatus = CubitStates.initial,
  });

  SettingsLoaded copyWith({
    List<SettingItemModel>? settings,
    bool? isNotificationEnabled,
    CubitStates? notificationStatus,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationStatus: notificationStatus ?? this.notificationStatus,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isNotificationEnabled,
    notificationStatus,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SettingState {
  CubitStates notificationStatus;
  final List<SettingItemModel> settings;
  final bool isNotificationEnabled;

  SettingState({
    this.notificationStatus = CubitStates.initial,
    this.settings = const [],
    this.isNotificationEnabled = false,
  });

  SettingState copyWith({
    CubitStates? notificationStatus,
    List<SettingItemModel>? settings,
    bool? isNotificationEnabled,
  }) {
    return SettingState(
      notificationStatus: notificationStatus ?? this.notificationStatus,
      settings: settings ?? this.settings,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
