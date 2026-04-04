import 'package:geolocator/geolocator.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

part 'marriage_location_state.dart';

class MarriageLocationCubit extends Cubit<MarriageLocationState> {
  MarriageLocationCubit(this._repository) : super(MarriageLocationInitial());

  final MarriageRepository _repository;
  int _denialCount = 0; // متتبع لعدد مرات الرفض

  Future<void> checkAndSetLocation({bool requestPermission = true}) async {
    emit(MarriageLocationLoading());

    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(MarriageLocationServiceDisabled('location_service_disabled_desc'));
        return;
      }

      // 2. Check for location permission.
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        emit(
          MarriageLocationPermissionDenied(
            'location_permission_denied_forever',
            isForever: true,
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        // إذا تم الرفض مرة واحدة أو أكثر نطلب منه التوجه للإعدادات للحل اليدوي
        if (_denialCount >= 1) {
          emit(
            MarriageLocationPermissionDenied(
              'location_permission_denied_multiple',
              isForever: true,
            ),
          );
          return;
        }

        if (requestPermission) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _denialCount++;
            if (_denialCount >= 1) {
              emit(
                MarriageLocationPermissionDenied(
                  'location_permission_denied_multiple',
                  isForever: true,
                ),
              );
            } else {
              emit(
                MarriageLocationPermissionDenied(
                  'location_permission_required',
                  isForever: false,
                ),
              );
            }
            return;
          } else if (permission == LocationPermission.deniedForever) {
            emit(
              MarriageLocationPermissionDenied(
                'location_permission_denied_forever',
                isForever: true,
              ),
            );
            return;
          }
        } else {
          emit(
            MarriageLocationPermissionDenied(
              'location_permission_required',
              isForever: (_denialCount >= 1),
            ),
          );
          return;
        }
      }

      // 3. Get the current location. (With timeout so it doesn't hang indefinitely)
      final Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );

      // 4. Send to backend.
      final result = await _repository.setUserLocation(
        lat: position.latitude,
        lng: position.longitude,
      );

      result.fold(
        (failure) => emit(MarriageLocationError(failure.message)),
        (_) => emit(MarriageLocationSuccess()),
      );
    } catch (e) {
      emit(MarriageLocationError('location_fetch_error'));
    }
  }
}
