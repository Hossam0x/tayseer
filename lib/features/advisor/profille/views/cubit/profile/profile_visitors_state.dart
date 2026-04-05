import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';

abstract class ProfileVisitorsState {}

class ProfileVisitorsInitial extends ProfileVisitorsState {}

class ProfileVisitorsLoading extends ProfileVisitorsState {}

class ProfileVisitorsSuccess extends ProfileVisitorsState {
  final List<ProfileVisitorModel> visitors;
  final bool isSubscribed;
  final String subscriptionType;

  ProfileVisitorsSuccess({
    required this.visitors,
    required this.isSubscribed,
    this.subscriptionType = 'free',
  });
}

class ProfileVisitorsFailure extends ProfileVisitorsState {
  final String errorMessage;

  ProfileVisitorsFailure(this.errorMessage);
}
