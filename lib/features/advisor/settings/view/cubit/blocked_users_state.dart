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

  const BlockedUsersLoaded({
    required this.blockedUsers,
    this.actionError,
    this.actionSuccess,
  });

  BlockedUsersLoaded copyWith({
    List<BlockedUserModel>? blockedUsers,
    String? actionError,
    String? actionSuccess,
  }) {
    return BlockedUsersLoaded(
      blockedUsers: blockedUsers ?? this.blockedUsers,
      actionError: actionError, // Intentionally not keeping previous
      actionSuccess: actionSuccess, // Intentionally not keeping previous
    );
  }

  @override
  List<Object?> get props => [blockedUsers, actionError, actionSuccess];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
