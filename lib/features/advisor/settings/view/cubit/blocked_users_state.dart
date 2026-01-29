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

  const BlockedUsersLoaded({required this.blockedUsers});

  @override
  List<Object?> get props => [blockedUsers];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
