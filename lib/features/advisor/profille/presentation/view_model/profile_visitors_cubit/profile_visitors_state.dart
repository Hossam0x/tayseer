import 'package:meta/meta.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';

@immutable
abstract class ProfileVisitorsState {}

class ProfileVisitorsInitial extends ProfileVisitorsState {}

class ProfileVisitorsLoading extends ProfileVisitorsState {}

class ProfileVisitorsSuccess extends ProfileVisitorsState {
  final List<ProfileVisitorModel> visitors;
  final bool isSubscribed;

  ProfileVisitorsSuccess({required this.visitors, required this.isSubscribed});
}

class ProfileVisitorsFailure extends ProfileVisitorsState {
  final String errorMessage;

  ProfileVisitorsFailure(this.errorMessage);
}
