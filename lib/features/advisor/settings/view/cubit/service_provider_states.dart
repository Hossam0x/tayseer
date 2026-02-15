import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_models.dart';

// ============================================
// 📌 SESSION PRICING STATE
// ============================================
class SessionPricingState extends Equatable {
  final CubitStates state;
  final ServiceProviderRequest? serviceProvider;
  final ServiceProviderRequest? originalServiceProvider;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaving;
  final Map<String, SessionTypeModel> sessionTypes;
  final bool hasChanges;

  const SessionPricingState({
    this.state = CubitStates.initial,
    this.serviceProvider,
    this.originalServiceProvider,
    this.errorMessage,
    this.successMessage,
    this.isSaving = false,
    required this.sessionTypes,
    required this.hasChanges,
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
      hasChanges: false,
    );
  }

  SessionPricingState copyWith({
    CubitStates? state,
    ServiceProviderRequest? serviceProvider,
    ServiceProviderRequest? originalServiceProvider,
    String? errorMessage,
    String? successMessage,
    bool? isSaving,
    Map<String, SessionTypeModel>? sessionTypes,
    bool? hasChanges,
  }) {
    return SessionPricingState(
      state: state ?? this.state,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      originalServiceProvider:
          originalServiceProvider ?? this.originalServiceProvider,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaving: isSaving ?? this.isSaving,
      sessionTypes: sessionTypes ?? this.sessionTypes,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
    state,
    serviceProvider,
    originalServiceProvider,
    errorMessage,
    successMessage,
    isSaving,
    sessionTypes,
    hasChanges,
  ];
}

// ============================================
// 📌 APPOINTMENTS STATE
// ============================================
class AppointmentsState extends Equatable {
  final CubitStates state;
  final ServiceProviderRequest? serviceProvider;
  final ServiceProviderRequest? originalServiceProvider;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaving;
  final List<WeeklyAvailabilityModel> weeklyAvailability;
  final bool hasChanges;

  const AppointmentsState({
    this.state = CubitStates.initial,
    this.serviceProvider,
    this.originalServiceProvider,
    this.errorMessage,
    this.successMessage,
    this.isSaving = false,
    required this.weeklyAvailability,
    required this.hasChanges,
  });

  factory AppointmentsState.initial() {
    return AppointmentsState(
      weeklyAvailability: List.generate(7, (index) {
        return WeeklyAvailabilityModel(
          dayOfWeek: index,
          isEnabled: index == 0 || index == 1,
          timeSlots: index == 0
              ? [
                  TimeSlotModel(start: '10:00', end: '12:00'),
                  TimeSlotModel(start: '14:00', end: '17:00'),
                ]
              : index == 1
              ? [TimeSlotModel(start: '09:00', end: '17:00')]
              : [],
        );
      }),
      hasChanges: false,
    );
  }

  AppointmentsState copyWith({
    CubitStates? state,
    ServiceProviderRequest? serviceProvider,
    ServiceProviderRequest? originalServiceProvider,
    String? errorMessage,
    String? successMessage,
    bool? isSaving,
    List<WeeklyAvailabilityModel>? weeklyAvailability,
    bool? hasChanges,
  }) {
    return AppointmentsState(
      state: state ?? this.state,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      originalServiceProvider:
          originalServiceProvider ?? this.originalServiceProvider,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaving: isSaving ?? this.isSaving,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
    state,
    serviceProvider,
    originalServiceProvider,
    errorMessage,
    successMessage,
    isSaving,
    weeklyAvailability,
    hasChanges,
  ];
}
