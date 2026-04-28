import 'package:tayseer/features/advisor/settings/data/models/service_provider_models.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_repository.dart';
import 'package:tayseer/my_import.dart';
import 'service_provider_states.dart';

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
    if (!updatedSessionTypes.containsKey(sessionKey)) return;

    final old = updatedSessionTypes[sessionKey]!;
    updatedSessionTypes[sessionKey] = SessionTypeModel(
      duration: old.duration,
      price: price,
      currency: old.currency,
      isEnabled: old.isEnabled,
      numberOfSessions: old.numberOfSessions,
      type: old.type,
    );

    emit(
      state.copyWith(
        sessionTypes: updatedSessionTypes,
        hasChanges: _hasSessionTypesChanged(updatedSessionTypes),
      ),
    );
  }

  void toggleSessionStatus(String sessionKey, bool isEnabled) {
    final updatedSessionTypes = Map<String, SessionTypeModel>.from(
      state.sessionTypes,
    );
    if (!updatedSessionTypes.containsKey(sessionKey)) return;

    final old = updatedSessionTypes[sessionKey]!;
    updatedSessionTypes[sessionKey] = SessionTypeModel(
      duration: old.duration,
      price: old.price,
      currency: old.currency,
      isEnabled: isEnabled,
      numberOfSessions: old.numberOfSessions,
      type: old.type,
    );

    emit(
      state.copyWith(
        sessionTypes: updatedSessionTypes,
        hasChanges: _hasSessionTypesChanged(updatedSessionTypes),
      ),
    );
  }

  void updateSessionNumberOfSessions(String sessionKey, int? count) {
    final updatedSessionTypes = Map<String, SessionTypeModel>.from(
      state.sessionTypes,
    );
    if (!updatedSessionTypes.containsKey(sessionKey)) return;

    final old = updatedSessionTypes[sessionKey]!;
    updatedSessionTypes[sessionKey] = SessionTypeModel(
      duration: old.duration,
      price: old.price,
      currency: old.currency,
      isEnabled: old.isEnabled,
      numberOfSessions: count,
      type: old.type,
    );

    emit(
      state.copyWith(
        sessionTypes: updatedSessionTypes,
        hasChanges: _hasSessionTypesChanged(updatedSessionTypes),
      ),
    );
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
      if (current.numberOfSessions != original.numberOfSessions) return true;
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
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (response) => emit(
        state.copyWith(
          isSaving: false,
          serviceProvider: response.data,
          originalServiceProvider: response.data,
          sessionTypes: response.data?.sessionTypes ?? state.sessionTypes,
          hasChanges: false,
          successMessage: 'changes_saved_successfully',
          state: CubitStates.success,
        ),
      ),
    );
  }

  void addSessionToList({
    required String key,
    required SessionTypeModel session,
  }) {
    final updated = Map<String, SessionTypeModel>.from(state.sessionTypes);
    updated[key] = session;
    emit(
      state.copyWith(
        sessionTypes: updated,
        hasChanges: _hasSessionTypesChanged(updated),
      ),
    );
  }

  void removeSessionFromList(String key) {
    final updated = Map<String, SessionTypeModel>.from(state.sessionTypes);
    updated.remove(key);
    emit(
      state.copyWith(
        sessionTypes: updated,
        hasChanges: _hasSessionTypesChanged(updated),
      ),
    );
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
  void clearSuccess() => emit(state.copyWith(successMessage: null));
}
