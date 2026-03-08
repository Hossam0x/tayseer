import 'package:equatable/equatable.dart';
import '../../data/models/blocked_user_model.dart';

abstract class BlockedUsersState extends Equatable {
  const BlockedUsersState();

  @override
  List<Object?> get props => [];
}

class BlockedUsersInitial extends BlockedUsersState {}

class BlockedUsersLoading extends BlockedUsersState {}

class BlockedUsersLoaded extends BlockedUsersState {
  final List<BlockedUserModel> blockedUsers;
  final String? actionError;
  final String? actionSuccess;
  final bool isActionKey; // Flag to indicate if message is a translation key

  const BlockedUsersLoaded({
    required this.blockedUsers,
    this.actionError,
    this.actionSuccess,
    this.isActionKey = true, // Default to true for translation keys
  });

  BlockedUsersLoaded copyWith({
    List<BlockedUserModel>? blockedUsers,
    String? actionError,
    String? actionSuccess,
    bool? isActionKey,
  }) {
    return BlockedUsersLoaded(
      blockedUsers: blockedUsers ?? this.blockedUsers,
      actionError: actionError, // Intentionally not keeping previous
      actionSuccess: actionSuccess, // Intentionally not keeping previous
      isActionKey: isActionKey ?? this.isActionKey,
    );
  }

  @override
  List<Object?> get props => [
    blockedUsers,
    actionError,
    actionSuccess,
    isActionKey,
  ];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
