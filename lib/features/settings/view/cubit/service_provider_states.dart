import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/settings/data/models/service_provider_models.dart';

// ============================================
// 📌 SESSION PRICING STATE
// ============================================
class SessionPricingState extends Equatable {
  final CubitStates state;
  final ServiceProviderRequest? serviceProvider;
  final String? errorMessage;
  final bool isSaving;
  final Map<String, SessionTypeModel> sessionTypes;

  const SessionPricingState({
    this.state = CubitStates.initial,
    this.serviceProvider,
    this.errorMessage,
    this.isSaving = false,
    required this.sessionTypes,
  });

  factory SessionPricingState.initial() {
    return SessionPricingState(
      sessionTypes: {
        '30min': SessionTypeModel(
          duration: 30,
          price: 100,
          currency: 'SAR',
          isEnabled: true,
        ),
        '60min': SessionTypeModel(
          duration: 60,
          price: 180,
          currency: 'SAR',
          isEnabled: true,
        ),
      },
    );
  }

  SessionPricingState copyWith({
    CubitStates? state,
    ServiceProviderRequest? serviceProvider,
    String? errorMessage,
    bool? isSaving,
    Map<String, SessionTypeModel>? sessionTypes,
  }) {
    return SessionPricingState(
      state: state ?? this.state,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      sessionTypes: sessionTypes ?? this.sessionTypes,
    );
  }

  @override
  List<Object?> get props => [
    state,
    serviceProvider,
    errorMessage,
    isSaving,
    sessionTypes,
  ];
}

// ============================================
// 📌 APPOINTMENTS STATE
// ============================================
class AppointmentsState extends Equatable {
  final CubitStates state;
  final ServiceProviderRequest? serviceProvider;
  final String? errorMessage;
  final bool isSaving;
  final List<WeeklyAvailabilityModel> weeklyAvailability;

  const AppointmentsState({
    this.state = CubitStates.initial,
    this.serviceProvider,
    this.errorMessage,
    this.isSaving = false,
    required this.weeklyAvailability,
  });

  factory AppointmentsState.initial() {
    return AppointmentsState(
      weeklyAvailability: List.generate(7, (index) {
        return WeeklyAvailabilityModel(
          dayOfWeek: index,
          isEnabled:
              index == 0 ||
              index == 1, // Saturday and Sunday enabled by default
          timeSlots: index == 0 || index == 1
              ? [TimeSlotModel(start: '09:00', end: '17:00')]
              : [],
        );
      }),
    );
  }

  AppointmentsState copyWith({
    CubitStates? state,
    ServiceProviderRequest? serviceProvider,
    String? errorMessage,
    bool? isSaving,
    List<WeeklyAvailabilityModel>? weeklyAvailability,
  }) {
    return AppointmentsState(
      state: state ?? this.state,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
    );
  }

  @override
  List<Object?> get props => [
    state,
    serviceProvider,
    errorMessage,
    isSaving,
    weeklyAvailability,
  ];
}
