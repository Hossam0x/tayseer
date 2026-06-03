part of 'message_details_cubit.dart';

abstract class MessageDetailsState {}

class MessageDetailsInitial extends MessageDetailsState {}

class MessageDetailsLoading extends MessageDetailsState {}

class MessageDetailsLoaded extends MessageDetailsState {
  final MessageDetailsModel details;
  MessageDetailsLoaded(this.details);
}

class MessageDetailsError extends MessageDetailsState {
  final String message;
  MessageDetailsError(this.message);
}
