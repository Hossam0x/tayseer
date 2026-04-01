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
  final int timestamp;

  const MembershipLoaded({
    required this.sub,
    this.actionSuccess,
    this.actionError,
    this.isCancelLoading = false,
    this.timestamp = 0,
  });

  MembershipLoaded copyWith({
    MySubscriptionModel? sub,
    String? actionSuccess,
    String? actionError,
    bool clearMessages = false,
    bool? isCancelLoading,
    int? timestamp,
  }) {
    return MembershipLoaded(
      sub: sub ?? this.sub,
      actionSuccess: clearMessages ? null : actionSuccess,
      actionError: clearMessages ? null : actionError,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    sub,
    actionSuccess,
    actionError,
    isCancelLoading,
    timestamp,
  ];
}

class MembershipNoSubscription extends MembershipState {}

class MembershipError extends MembershipState {
  final String message;

  const MembershipError({required this.message});

  @override
  List<Object?> get props => [message];
}
