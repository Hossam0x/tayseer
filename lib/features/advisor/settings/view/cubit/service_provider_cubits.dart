import 'package:tayseer/features/advisor/settings/data/models/service_provider_models.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_repository.dart';
import 'package:tayseer/my_import.dart';
import 'service_provider_states.dart';

// ============================================
// 📌 SESSION PRICING CUBIT
// ============================================
class SessionPricingCubit extends Cubit<SessionPricingState> {
  final ServiceProviderRepository _repository;

  SessionPricingCubit(this._repository) : super(SessionPricingState.initial()) {
    loadServiceProvider();
  }

  Future<void> loadServiceProvider() async {
    emit(state.copyWith(state: CubitStates.loading));

    final result = await _repository.getServiceProvider();
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        if (response.data != null) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              serviceProvider: response.data,
              originalServiceProvider: response.data,
              sessionTypes: response.data!.sessionTypes,
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
              sessionTypes: defaultRequest.sessionTypes,
              hasChanges: false,
            ),
          );
        }
      },
    );
  }

  void updateSessionPrice(String sessionKey, int price) {
    final updatedSessionTypes = Map<String, SessionTypeModel>.from(
      state.sessionTypes,
    );

    if (updatedSessionTypes.containsKey(sessionKey)) {
      final oldSession = updatedSessionTypes[sessionKey]!;
      updatedSessionTypes[sessionKey] = SessionTypeModel(
        duration: oldSession.duration,
        price: price,
        currency: oldSession.currency,
        isEnabled: oldSession.isEnabled,
      );

      final hasChanges = _hasSessionTypesChanged(updatedSessionTypes);

      emit(
        state.copyWith(
          sessionTypes: updatedSessionTypes,
          hasChanges: hasChanges,
        ),
      );
    }
  }

  void toggleSessionStatus(String sessionKey, bool isEnabled) {
    final updatedSessionTypes = Map<String, SessionTypeModel>.from(
      state.sessionTypes,
    );

    if (updatedSessionTypes.containsKey(sessionKey)) {
      final oldSession = updatedSessionTypes[sessionKey]!;
      updatedSessionTypes[sessionKey] = SessionTypeModel(
        duration: oldSession.duration,
        price: oldSession.price,
        currency: oldSession.currency,
        isEnabled: isEnabled,
      );

      final hasChanges = _hasSessionTypesChanged(updatedSessionTypes);

      emit(
        state.copyWith(
          sessionTypes: updatedSessionTypes,
          hasChanges: hasChanges,
        ),
      );
    }
  }

  bool _hasSessionTypesChanged(Map<String, SessionTypeModel> currentTypes) {
    if (state.originalServiceProvider == null) return true;

    final originalTypes = state.originalServiceProvider!.sessionTypes;

    for (final key in currentTypes.keys) {
      final current = currentTypes[key];
      final original = originalTypes[key];

      if (original == null) return true;
      if (current!.price != original.price) return true;
      if (current.isEnabled != original.isEnabled) return true;
    }

    return false;
  }

  Future<void> saveChanges() async {
    if (!state.hasChanges) return;

    emit(
      state.copyWith(isSaving: true, errorMessage: null, successMessage: null),
    );

    final currentProvider = state.serviceProvider;
    final request = currentProvider != null
        ? ServiceProviderRequest(
            sessionTypes: state.sessionTypes,
            weeklyAvailability: currentProvider.weeklyAvailability,
            timezone: currentProvider.timezone,
          )
        : ServiceProviderRequest.defaultRequest();

    final result = await _repository.updateServiceProvider(request: request);

    result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (response) {
        emit(
          state.copyWith(
            isSaving: false,
            serviceProvider: response.data,
            originalServiceProvider: response.data,
            sessionTypes: response.data?.sessionTypes ?? state.sessionTypes,
            hasChanges: false,
            successMessage: 'changes_saved_successfully',
            state: CubitStates.success,
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }
}

// ============================================
// 📌 APPOINTMENTS CUBIT
// ============================================
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
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
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
      (day) => day.dayOfWeek == dayOfWeek,
    );
    if (index != -1) {
      final oldDay = updatedAvailability[index];
      updatedAvailability[index] = WeeklyAvailabilityModel(
        dayOfWeek: oldDay.dayOfWeek,
        isEnabled: isEnabled,
        timeSlots: isEnabled ? oldDay.timeSlots : [],
      );

      final hasChanges = _hasAvailabilityChanged(updatedAvailability);

      emit(
        state.copyWith(
          weeklyAvailability: updatedAvailability,
          hasChanges: hasChanges,
        ),
      );
    }
  }

  void updateDayTimeSlot(int dayOfWeek, String startTime, String endTime) {
    final updatedAvailability = List<WeeklyAvailabilityModel>.from(
      state.weeklyAvailability,
    );

    final index = updatedAvailability.indexWhere(
      (day) => day.dayOfWeek == dayOfWeek,
    );
    if (index != -1) {
      final oldDay = updatedAvailability[index];
      updatedAvailability[index] = WeeklyAvailabilityModel(
        dayOfWeek: oldDay.dayOfWeek,
        isEnabled: oldDay.isEnabled,
        timeSlots: [TimeSlotModel(start: startTime, end: endTime)],
      );

      final hasChanges = _hasAvailabilityChanged(updatedAvailability);

      emit(
        state.copyWith(
          weeklyAvailability: updatedAvailability,
          hasChanges: hasChanges,
        ),
      );
    }
  }

  bool _hasAvailabilityChanged(
    List<WeeklyAvailabilityModel> currentAvailability,
  ) {
    if (state.originalServiceProvider == null) return true;

    final originalAvailability =
        state.originalServiceProvider!.weeklyAvailability;

    if (currentAvailability.length != originalAvailability.length) return true;

    for (int i = 0; i < currentAvailability.length; i++) {
      final current = _normalizeDay(currentAvailability[i]);
      final original = _normalizeDay(originalAvailability[i]);

      if (current != original) return true;
    }

    return false;
  }

  WeeklyAvailabilityModel _normalizeDay(WeeklyAvailabilityModel day) {
    bool isActuallyEnabled = day.isEnabled;
    if (isActuallyEnabled) {
      if (day.timeSlots.isEmpty) {
        isActuallyEnabled = false;
      } else {
        bool hasValidSlot = false;
        for (final slot in day.timeSlots) {
          if (slot.start != '00:00' &&
              slot.start != '' &&
              slot.end != '00:00' &&
              slot.end != '') {
            hasValidSlot = true;
            break;
          }
        }
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
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (response) {
        emit(
          state.copyWith(
            isSaving: false,
            serviceProvider: response.data,
            originalServiceProvider: response.data,
            weeklyAvailability:
                response.data?.weeklyAvailability ?? state.weeklyAvailability,
            hasChanges: false,
            successMessage: 'changes_saved_successfully',
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }
}
