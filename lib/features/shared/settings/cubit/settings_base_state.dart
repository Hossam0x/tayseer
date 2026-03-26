import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';

/// Base states shared by both [SettingsCubit] and [UserProfileCubit].
abstract class SettingsBaseState extends Equatable {
  const SettingsBaseState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsBaseState {}

class SettingsLoading extends SettingsBaseState {}

class SettingsError extends SettingsBaseState {
  final String message;
  const SettingsError({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Minimal shared loaded state — each feature extends this with its own fields.
abstract class SettingsLoadedBase extends SettingsBaseState {
  final List<SettingItemModel> settings;
  final bool isNotificationEnabled;
  final int actionTimestamp;

  const SettingsLoadedBase({
    required this.settings,
    this.isNotificationEnabled = false,
    this.actionTimestamp = 0,
  });
}
