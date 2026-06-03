import 'package:tayseer/features/advisor/settings/data/models/service_provider_models.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_repository.dart';
import 'package:tayseer/my_import.dart';
import 'service_provider_states.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final ServiceProviderRepository _repository;

  AppointmentsCubit(this._repository) : super(AppointmentsState.initial()) {
    loadServiceProvider();
  }

  Future<void> loadServiceProvider() async {
    emit(state.copyWith(state: CubitStates.loading));

    final result = await _repository.getServiceProvider();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) {
        if (response.data != null) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              serviceProvider: response.data,
              originalServiceProvider: response.data,
              weeklyAvailability: response.data!.weeklyAvailability,
              hasChanges: false,
            ),
          );
        } else {
          final defaultRequest = ServiceProviderRequest.defaultRequest();
          emit(
            state.copyWith(
              state: CubitStates.success,
              serviceProvider: defaultRequest,
              originalServiceProvider: defaultRequest,
              weeklyAvailability: defaultRequest.weeklyAvailability,
              hasChanges: false,
            ),
          );
        }
      },
    );
  }

  void toggleDayStatus(int dayOfWeek, bool isEnabled) {
    final updatedAvailability = List<WeeklyAvailabilityModel>.from(
      state.weeklyAvailability,
    );
    final index = updatedAvailability.indexWhere(
      (d) => d.dayOfWeek == dayOfWeek,
    );
    if (index == -1) return;

    final old = updatedAvailability[index];
    updatedAvailability[index] = WeeklyAvailabilityModel(
      dayOfWeek: old.dayOfWeek,
      isEnabled: isEnabled,
      timeSlots: isEnabled ? old.timeSlots : [],
    );

    emit(
      state.copyWith(
        weeklyAvailability: updatedAvailability,
        hasChanges: _hasAvailabilityChanged(updatedAvailability),
      ),
    );
  }

  void updateDayTimeSlot(int dayOfWeek, String startTime, String endTime) {
    final updatedAvailability = List<WeeklyAvailabilityModel>.from(
      state.weeklyAvailability,
    );
    final index = updatedAvailability.indexWhere(
      (d) => d.dayOfWeek == dayOfWeek,
    );
    if (index == -1) return;

    final old = updatedAvailability[index];
    updatedAvailability[index] = WeeklyAvailabilityModel(
      dayOfWeek: old.dayOfWeek,
      isEnabled: old.isEnabled,
      timeSlots: [TimeSlotModel(start: startTime, end: endTime)],
    );

    emit(
      state.copyWith(
        weeklyAvailability: updatedAvailability,
        hasChanges: _hasAvailabilityChanged(updatedAvailability),
      ),
    );
  }

  bool _hasAvailabilityChanged(
    List<WeeklyAvailabilityModel> currentAvailability,
  ) {
    if (state.originalServiceProvider == null) return true;
    final originalAvailability =
        state.originalServiceProvider!.weeklyAvailability;
    if (currentAvailability.length != originalAvailability.length) return true;

    for (int i = 0; i < currentAvailability.length; i++) {
      if (_normalizeDay(currentAvailability[i]) !=
          _normalizeDay(originalAvailability[i])) {
        return true;
      }
    }
    return false;
  }

  WeeklyAvailabilityModel _normalizeDay(WeeklyAvailabilityModel day) {
    bool isActuallyEnabled = day.isEnabled;
    if (isActuallyEnabled) {
      if (day.timeSlots.isEmpty) {
        isActuallyEnabled = false;
      } else {
        final hasValidSlot = day.timeSlots.any(
          (slot) =>
              slot.start != '00:00' &&
              slot.start != '' &&
              slot.end != '00:00' &&
              slot.end != '',
        );
        if (!hasValidSlot) isActuallyEnabled = false;
      }
    }
    return WeeklyAvailabilityModel(
      dayOfWeek: day.dayOfWeek,
      isEnabled: isActuallyEnabled,
      timeSlots: isActuallyEnabled ? day.timeSlots : [],
    );
  }

  Future<void> saveChanges() async {
    if (!state.hasChanges) return;
    emit(
      state.copyWith(isSaving: true, successMessage: null, errorMessage: null),
    );

    final currentProvider = state.serviceProvider;
    final normalizedAvailability = state.weeklyAvailability
        .map(_normalizeDay)
        .toList();

    final request = currentProvider != null
        ? ServiceProviderRequest(
            sessionTypes: currentProvider.sessionTypes,
            weeklyAvailability: normalizedAvailability,
            timezone: currentProvider.timezone,
          )
        : ServiceProviderRequest.defaultRequest();

    final result = await _repository.updateServiceProvider(request: request);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isSaving: false,
          serviceProvider: response.data,
          originalServiceProvider: response.data,
          weeklyAvailability:
              response.data?.weeklyAvailability ?? state.weeklyAvailability,
          hasChanges: false,
          successMessage: 'changes_saved_successfully',
        ),
      ),
    );
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
  void clearSuccess() => emit(state.copyWith(successMessage: null));
}
