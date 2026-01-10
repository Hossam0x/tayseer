// lib/features/advisor/event/view_model/events_cubit.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:tayseer/features/advisor/event/model/location_result_model.dart';
import 'package:tayseer/features/advisor/event/model/my_event_model.dart';
import 'package:tayseer/features/advisor/event/repo/event_repo.dart';
import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/my_import.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(const EventsState());

  // ==================== Controllers ====================
  final creatEventformKey = GlobalKey<FormState>();
  final eventTitleController = TextEditingController();
  final eventDescriptionController = TextEditingController();
  final eventPriceBeforeDiscountController = TextEditingController();
  final eventPriceAfterDiscountController = TextEditingController();

  static const gmaps.LatLng _defaultPosition = gmaps.LatLng(30.0444, 31.2357);

  //                         VIDEO METHODS

  void setPickedVideo(XFile video) {
    emit(state.copyWith(pickedVideo: video));
  }

  XFile? get pickedVideo => state.pickedVideo;

  void removePickedVideo() {
    debugPrint('removePickedVideo called'); // Debug log
    emit(state.copyWith(pickedVideo: null));
  }

  void setVideoLoading(bool value) {
    emit(state.copyWith(isVideoLoading: value));
  }

  void setVideoLoaded() {
    emit(state.copyWith(isVideoLoading: false));
  }

  //                        IMAGES METHODS

  List<XFile> get pickedImages => state.pickedImages;

  void setPickedImages(List<XFile> images) {
    emit(state.copyWith(pickedImages: images));
  }

  void addPickedImages(List<XFile> images) {
    final newList = List<XFile>.from(state.pickedImages)..addAll(images);
    emit(state.copyWith(pickedImages: newList));
  }

  void removePickedImageAt(int index) {
    final newList = List<XFile>.from(state.pickedImages);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      emit(state.copyWith(pickedImages: newList));
    }
  }

  void clearPickedImages() {
    emit(state.copyWith(pickedImages: const []));
  }

  //                      EVENT TYPE METHODS

  String? get duration => state.duration;

  void setDuration(String? value) {
    emit(state.copyWith(duration: value));
  }

  // Backward-compatible alias used by some UI code
  void setExperienceYears(String? value) => setDuration(value);

  //                   DATE & TIME METHODS

  DateTime? get eventDate => state.eventDate;

  void setEventDate(DateTime? date) {
    emit(state.copyWith(eventDate: date));
  }

  TimeOfDay? get startTime => state.startTime;

  void setStartTime(TimeOfDay? time) {
    emit(state.copyWith(startTime: time));
  }

  // number Of Attendees
  String? get numberOfAttendees => state.numberOfAttendees;

  void setnumberOfAttendees(String? val) {
    emit(state.copyWith(numberOfAttendees: val));
  }

  void numberOfffAttendees(String? value) => setnumberOfAttendees(value);

  //                      LOCATION METHODS

  double? get latitude => state.latitude;
  double? get longitude => state.longitude;
  String? get locationAddress => state.locationAddress;
  bool get hasLocation => state.hasLocation;

  /// التحقق من صلاحيات الموقع
  Future<LocationPermissionResult> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult(
        granted: false,
        message: 'خدمة الموقع غير مفعلة، يرجى تفعيلها',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionResult(
          granted: false,
          message: 'تم رفض إذن الموقع',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult(
        granted: false,
        message: 'إذن الموقع مرفوض نهائياً، يرجى تفعيله من الإعدادات',
      );
    }

    return LocationPermissionResult(granted: true);
  }

  /// جلب الموقع الحالي للجهاز
  Future<void> getCurrentLocation() async {
    emit(state.copyWith(isLoadingLocation: true));

    final permissionResult = await handleLocationPermission();
    if (!permissionResult.granted) {
      emit(
        state.copyWith(
          isLoadingLocation: false,
          errorMessage: permissionResult.message,
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentPos = gmaps.LatLng(position.latitude, position.longitude);

      final address = await _getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      final marker = _createMarker(
        currentPos,
        'موقعي الحالي',
        gmaps.BitmapDescriptor.hueBlue,
      );

      emit(
        state.copyWith(
          currentPosition: currentPos,
          selectedPosition: currentPos,
          currentAddress: address,
          selectedAddress: address,
          latitude: position.latitude,
          longitude: position.longitude,
          locationAddress: address,
          markers: {marker},
          isLoadingLocation: false,
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      emit(
        state.copyWith(
          isLoadingLocation: false,
          errorMessage: 'حدث خطأ في جلب الموقع',
        ),
      );
    }
  }

  /// تحويل الإحداثيات إلى عنوان نصي
  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        return address.isNotEmpty ? address : 'عنوان غير معروف';
      }
      return 'عنوان غير معروف';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'خطأ في جلب العنوان';
    }
  }

  /// إنشاء ماركر
  gmaps.Marker _createMarker(gmaps.LatLng position, String title, double hue) {
    return gmaps.Marker(
      markerId: const gmaps.MarkerId('selected_location'),
      position: position,
      infoWindow: gmaps.InfoWindow(title: title),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(hue),
    );
  }

  /// عند الضغط على الخريطة
  Future<void> onMapTapped(gmaps.LatLng position) async {
    final marker = _createMarker(
      position,
      'المكان المختار',
      gmaps.BitmapDescriptor.hueRed,
    );

    emit(
      state.copyWith(
        selectedPosition: position,
        markers: {marker},
        isLoadingAddress: true,
      ),
    );

    final address = await _getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );

    emit(
      state.copyWith(
        selectedAddress: address,
        latitude: position.latitude,
        longitude: position.longitude,
        locationAddress: address,
        isLoadingAddress: false,
      ),
    );
  }

  void setLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    final position = gmaps.LatLng(latitude, longitude);
    final marker = _createMarker(
      position,
      'المكان المختار',
      gmaps.BitmapDescriptor.hueRed,
    );

    emit(
      state.copyWith(
        latitude: latitude,
        longitude: longitude,
        locationAddress: address,
        selectedPosition: position,
        selectedAddress: address,
        markers: {marker},
      ),
    );
  }

  /// مسح الموقع
  void clearLocation() {
    emit(
      state.copyWith(
        latitude: null,
        longitude: null,
        locationAddress: null,
        selectedPosition: null,
        selectedAddress: '',
        markers: const {},
      ),
    );
  }

  /// الحصول على الموقع الأولي للخريطة
  gmaps.LatLng get initialPosition => state.currentPosition ?? _defaultPosition;

  //                        API METHODS

  Future<void> getAdvisorEvents() async {
    try {
      emit(state.copyWith(advisorEventsState: CubitStates.loading));

      final either = await getIt<EventRepo>().getAdvisorEvents();

      either.fold(
        (failure) {
          emit(
            state.copyWith(
              advisorEventsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (advisorEvents) {
          emit(
            state.copyWith(
              advisorEvents: advisorEvents,
              advisorEventsState: CubitStates.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          advisorEventsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      emit(state.copyWith(deleteEventStatus: CubitStates.loading));

      final either = await getIt<EventRepo>().deleteEvent(id: id);

      either.fold(
        (failure) {
          emit(
            state.copyWith(
              deleteEventStatus: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          final updated = List<EventModel>.from(state.advisorEvents)
            ..removeWhere((e) => e.id == id);
          emit(
            state.copyWith(
              advisorEvents: updated,
              deleteEventStatus: CubitStates.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          deleteEventStatus: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getAllEvents() async {
    try {
      emit(state.copyWith(allEventsState: CubitStates.loading));

      final either = await getIt<EventRepo>().getAllEvents();

      either.fold(
        (failure) {
          emit(
            state.copyWith(
              allEventsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (allEvents) {
          emit(
            state.copyWith(
              allEvents: allEvents,
              allEventsState: CubitStates.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          allEventsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createEvent() async {
    if (!creatEventformKey.currentState!.validate()) {
      return;
    }

    try {
      emit(state.copyWith(advisorEventsState: CubitStates.loading));

      final either = await getIt<EventRepo>().createEvent(
        title: eventTitleController.text,
        description: eventDescriptionController.text,
        date: state.eventDate!.toIso8601String(),
        startTime:
            '${state.startTime!.hour}:${state.startTime!.minute.toString().padLeft(2, '0')}',
        priceBeforeDiscount: eventPriceBeforeDiscountController.text,
        priceAfterDiscount: eventPriceAfterDiscountController.text,
        duration: state.duration ?? '0',
        latitude: state.latitude!.toString(),
        longitude: state.longitude!.toString(),
        location: state.locationAddress!,
        images: state.pickedImages,
        video: state.pickedVideo,
        numberOfAttendees: state.numberOfAttendees ?? "0",
      );

      either.fold(
        (failure) {
          emit(
            state.copyWith(
              advisorEventsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (successMessage) {
          emit(state.copyWith(advisorEventsState: CubitStates.success));
          _clearForm();
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          advisorEventsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future _clearForm() async {
    eventTitleController.clear();
    eventDescriptionController.clear();
    eventPriceBeforeDiscountController.clear();
    eventPriceAfterDiscountController.clear();
    eventPriceAfterDiscountController.clear();
    clearPickedImages();
    removePickedVideo();
    clearLocation();
    setDuration(null);
    setStartTime(null);
    setEventDate(null);
    setnumberOfAttendees(null);
    emit(
      state.copyWith(
        pickedImages: const [],
        pickedVideo: null,
        isVideoLoading: false,
        numberOfAttendees: null,
        latitude: null,
        longitude: null,
        locationAddress: null,
        selectedPosition: null,
        selectedAddress: '',
        markers: const {},
      ),
    );
  }

  @override
  Future<void> close() {
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    eventPriceBeforeDiscountController.dispose();
    eventPriceAfterDiscountController.dispose();
    eventPriceAfterDiscountController.dispose();

    return super.close();
  }
}
