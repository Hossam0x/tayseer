import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';

abstract class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => [];
}

class MembershipInitial extends MembershipState {}

class MembershipLoading extends MembershipState {}

class MembershipLoaded extends MembershipState {
  final MySubscriptionModel sub;
  final String? actionSuccess;
  final String? actionError;
  final bool isCancelLoading;
  final bool isRestoreLoading;
  final bool isTransferLoading;
  final int timestamp;

  const MembershipLoaded({
    required this.sub,
    this.actionSuccess,
    this.actionError,
    this.isCancelLoading = false,
    this.isRestoreLoading = false,
    this.isTransferLoading = false,
    this.timestamp = 0,
  });

  MembershipLoaded copyWith({
    MySubscriptionModel? sub,
    String? actionSuccess,
    String? actionError,
    bool clearMessages = false,
    bool? isCancelLoading,
    bool? isRestoreLoading,
    bool? isTransferLoading,
    int? timestamp,
  }) {
    return MembershipLoaded(
      sub: sub ?? this.sub,
      actionSuccess: clearMessages ? null : actionSuccess,
      actionError: clearMessages ? null : actionError,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      isRestoreLoading: isRestoreLoading ?? this.isRestoreLoading,
      isTransferLoading: isTransferLoading ?? this.isTransferLoading,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    sub,
    actionSuccess,
    actionError,
    isCancelLoading,
    isRestoreLoading,
    isTransferLoading,
    timestamp,
  ];
}

class MembershipNoSubscription extends MembershipState {}

class MembershipNoSubscriptionRestoring extends MembershipState {}

/// Shown after a restore attempt with a message (success or failure).
class MembershipNoSubscriptionWithMessage extends MembershipState {
  final String message;
  final bool isSuccess;

  const MembershipNoSubscriptionWithMessage({
    required this.message,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [message, isSuccess];
}

/// Shown when the backend returns CONFLICT — subscription exists on another account.
class MembershipRestoreConflict extends MembershipState {
  final String message;
  final String purchaseId;

  const MembershipRestoreConflict({
    required this.message,
    required this.purchaseId,
  });

  @override
  List<Object?> get props => [message, purchaseId];
}

class MembershipError extends MembershipState {
  final String message;

  const MembershipError({required this.message});

  @override
  List<Object?> get props => [message];
}
