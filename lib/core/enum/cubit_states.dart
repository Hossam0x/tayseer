enum CubitStates {
  initial,
  loading,
  loadingMore,
  success,
  failure;

  static void printState({
    required String? stateName,
    required CubitStates? state,
  }) {
    if (state == null) return;

    String stateNameString() {
      switch (state) {
        case CubitStates.initial:
          return "Initial State";
        case CubitStates.loading:
          return "Loading State";
        case CubitStates.loadingMore:
          return "Loading More State";
        case CubitStates.success:
          return "Success State";
        case CubitStates.failure:
          return "Failure State";
      }
    }

    print("$stateName: ${stateNameString()}");
  }
}