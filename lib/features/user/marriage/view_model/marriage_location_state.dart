part of 'marriage_location_cubit.dart';

abstract class MarriageLocationState {}

class MarriageLocationInitial extends MarriageLocationState {}

class MarriageLocationLoading extends MarriageLocationState {}

class MarriageLocationSuccess extends MarriageLocationState {}

class MarriageLocationPermissionDenied extends MarriageLocationState {
  final bool isForever;
  final String message;

  MarriageLocationPermissionDenied(this.message, {this.isForever = false});
}

class MarriageLocationServiceDisabled extends MarriageLocationState {
  final String message;

  MarriageLocationServiceDisabled(this.message);
}

class MarriageLocationError extends MarriageLocationState {
  final String message;

  MarriageLocationError(this.message);
}
