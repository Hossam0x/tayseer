enum CubitStates {
  initial,
  loading,
  success,
  failure;

  static printState({
    required String? stateName,
    required CubitStates? state,
  }) {
    String stateNameString() {
      if (state == CubitStates.initial) {
        return "Initial State";
      } else if (state == CubitStates.loading) {
        return "Loading State";
      } else if (state == CubitStates.success) {
        return "Success State";
      } else {
        return "Failure State";
      }
    }

    state != null ? print("$stateName: ${stateNameString()}") : null;
  }
}
