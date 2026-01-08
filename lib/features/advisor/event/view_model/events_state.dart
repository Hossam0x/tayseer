// lib/features/advisor/event/view_model/events_state.dart

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:tayseer/features/advisor/event/model/my_event_model.dart';
import 'package:tayseer/my_import.dart';

// Sentinel used in copyWith to allow explicitly setting nullable fields to null
const _sentinel = Object();

class EventsState {
  // ==================== Events Data ====================
  final CubitStates advisorEventsState;
  final CubitStates allEventsState;
  final String? errorMessage;
  final List<EventModel> advisorEvents;
  final List<EventModel> allEvents;

  // ==================== Media ====================
  final List<XFile> pickedImages;
  final XFile? pickedVideo;
  final bool isVideoLoading;

  // ==================== Event Details ====================
  final String? duration;
  final DateTime? eventDate;
  final TimeOfDay? startTime;
  final String? numberOfAttendees;

  // ==================== Location ====================
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final gmaps.LatLng? currentPosition;
  final gmaps.LatLng? selectedPosition;
  final Set<gmaps.Marker> markers;
  final bool isLoadingLocation;
  final bool isLoadingAddress;
  final String currentAddress;
  final String selectedAddress;

  const EventsState({
    // Events
    this.advisorEventsState = CubitStates.initial,
    this.allEventsState = CubitStates.initial,
    this.errorMessage,
    this.advisorEvents = const [],
    this.allEvents = const [],
    // Media
    this.pickedImages = const [],
    this.pickedVideo,
    this.isVideoLoading = false,
    // Event Details
    this.duration,
    this.eventDate,
    this.startTime,
    this.numberOfAttendees,
    // Location
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.currentPosition,
    this.selectedPosition,
    this.markers = const {},
    this.isLoadingLocation = false,
    this.isLoadingAddress = false,
    this.currentAddress = '',
    this.selectedAddress = '',
  });

  // ✅ التحقق من وجود موقع
  bool get hasLocation => latitude != null && longitude != null;

  EventsState copyWith({
    // Events
    CubitStates? advisorEventsState,
    CubitStates? allEventsState,
    String? errorMessage,
    List<EventModel>? advisorEvents,
    List<EventModel>? allEvents,
    // Media
    List<XFile>? pickedImages,
    Object? pickedVideo = _sentinel,
    bool? isVideoLoading,
    // Event Details
    String? duration,
    DateTime? eventDate,
    TimeOfDay? startTime,
    String? numberOfAttendees,
    // Location
    double? latitude,
    double? longitude,
    String? locationAddress,
    gmaps.LatLng? currentPosition, // ✅
    gmaps.LatLng? selectedPosition, // ✅
    Set<gmaps.Marker>? markers, // ✅
    bool? isLoadingLocation,
    bool? isLoadingAddress,
    String? currentAddress,
    String? selectedAddress,
  }) {
    return EventsState(
      // Events
      advisorEventsState: advisorEventsState ?? this.advisorEventsState,
      allEventsState: allEventsState ?? this.allEventsState,
      errorMessage: errorMessage ?? this.errorMessage,
      advisorEvents: advisorEvents ?? this.advisorEvents,
      allEvents: allEvents ?? this.allEvents,
      // Media
      pickedImages: pickedImages ?? this.pickedImages,
      pickedVideo: pickedVideo == _sentinel
          ? this.pickedVideo
          : pickedVideo as XFile?,
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      // Event Details
      duration: duration ?? this.duration,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      numberOfAttendees: numberOfAttendees ?? this.numberOfAttendees,
      // Location
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      currentPosition: currentPosition ?? this.currentPosition,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      markers: markers ?? this.markers,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      currentAddress: currentAddress ?? this.currentAddress,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }
}
