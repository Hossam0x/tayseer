
import 'package:tayseer/my_import.dart';
import '../model/event_detail_model.dart';

class EventDetailState {
  final CubitStates eventDetailStatus;
  final CubitStates updateEventStatus;
  final String? errorMessage;
  final EventDetailModel? event;

  final DateTime? eventDate;
  final TimeOfDay? startTime;
  final String? duration;
  final String? numberOfAttendees;

  final List<XFile> pickedImages;
  final List<String> existingImages;

  const EventDetailState({
    this.eventDetailStatus = CubitStates.initial,
    this.updateEventStatus = CubitStates.initial,
    this.errorMessage,
    this.event,
    this.eventDate,
    this.startTime,
    this.duration,
    this.numberOfAttendees,
    this.pickedImages = const [],
    this.existingImages = const [],
  });

  EventDetailState copyWith({
    CubitStates? eventDetailStatus,
    CubitStates? updateEventStatus,
    String? errorMessage,
    EventDetailModel? event,
    DateTime? eventDate,
    TimeOfDay? startTime,
    String? duration,
    String? numberOfAttendees,
    List<XFile>? pickedImages,
    List<String>? existingImages,
  }) {
    return EventDetailState(
      eventDetailStatus: eventDetailStatus ?? this.eventDetailStatus,
      updateEventStatus: updateEventStatus ?? this.updateEventStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      event: event ?? this.event,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      numberOfAttendees: numberOfAttendees ?? this.numberOfAttendees,
      pickedImages: pickedImages ?? this.pickedImages,
      existingImages: existingImages ?? this.existingImages,
    );
  }

  EventDetailState reset() => const EventDetailState();
}