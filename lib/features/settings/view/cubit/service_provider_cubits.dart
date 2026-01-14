import 'package:tayseer/features/settings/data/models/service_provider_models.dart';
import 'package:tayseer/features/settings/data/models/service_provider_repository.dart';
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
              sessionTypes: response.data!.sessionTypes,
            ),
          );
        } else {
          emit(
            state.copyWith(
              state: CubitStates.success,
              sessionTypes:
                  ServiceProviderRequest.defaultRequest().sessionTypes,
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

      emit(state.copyWith(sessionTypes: updatedSessionTypes));
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

      emit(state.copyWith(sessionTypes: updatedSessionTypes));
    }
  }

  Future<void> saveChanges() async {
    emit(state.copyWith(isSaving: true));

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
            sessionTypes: response.data?.sessionTypes ?? state.sessionTypes,
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
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
              weeklyAvailability: response.data!.weeklyAvailability,
            ),
          );
        } else {
          emit(
            state.copyWith(
              state: CubitStates.success,
              weeklyAvailability:
                  ServiceProviderRequest.defaultRequest().weeklyAvailability,
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
        timeSlots: oldDay.timeSlots,
      );

      emit(state.copyWith(weeklyAvailability: updatedAvailability));
    }
  }

  // في AppointmentsCubit
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

      emit(state.copyWith(weeklyAvailability: updatedAvailability));
    }
  }

  Future<void> saveChanges() async {
    emit(state.copyWith(isSaving: true));

    final currentProvider = state.serviceProvider;
    final request = currentProvider != null
        ? ServiceProviderRequest(
            sessionTypes: currentProvider.sessionTypes,
            weeklyAvailability: state.weeklyAvailability,
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
            weeklyAvailability:
                response.data?.weeklyAvailability ?? state.weeklyAvailability,
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
