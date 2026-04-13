import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';

class RegardsPackagesState {
  final CubitStates status;
  final List<RegardsPackageModel> packages;
  final DateTime? regardsIncrementAt;
  final String? error;

  const RegardsPackagesState({
    this.status = CubitStates.initial,
    this.packages = const [],
    this.regardsIncrementAt,
    this.error,
  });

  RegardsPackagesState copyWith({
    CubitStates? status,
    List<RegardsPackageModel>? packages,
    DateTime? regardsIncrementAt,
    String? error,
  }) {
    return RegardsPackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      regardsIncrementAt: regardsIncrementAt ?? this.regardsIncrementAt,
      error: error ?? this.error,
    );
  }
}

class RegardsPackagesCubit extends Cubit<RegardsPackagesState> {
  final ApiService _apiService;

  RegardsPackagesCubit(this._apiService) : super(const RegardsPackagesState());

  Future<void> fetchPackages() async {
    if (state.status == CubitStates.loading) return;
    emit(state.copyWith(status: CubitStates.loading));
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.regardsPackages,
      );
      final data = RegardsPackagesResponse.fromJson(response);
      emit(state.copyWith(
        status: CubitStates.success,
        packages: data.packages,
        regardsIncrementAt: data.regardsIncrementAt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CubitStates.failure,
        error: e.toString(),
      ));
    }
  }
}
