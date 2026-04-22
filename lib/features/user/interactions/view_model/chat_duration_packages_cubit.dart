import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/user/interactions/data/model/chat_duration_package_model.dart';

class ChatDurationPackagesState {
  final CubitStates status;
  final List<ChatDurationPackageModel> packages;
  final String? error;

  const ChatDurationPackagesState({
    this.status = CubitStates.initial,
    this.packages = const [],
    this.error,
  });

  ChatDurationPackagesState copyWith({
    CubitStates? status,
    List<ChatDurationPackageModel>? packages,
    String? error,
  }) {
    return ChatDurationPackagesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      error: error ?? this.error,
    );
  }
}

class ChatDurationPackagesCubit extends Cubit<ChatDurationPackagesState> {
  final ApiService _apiService;

  ChatDurationPackagesCubit(this._apiService)
      : super(const ChatDurationPackagesState());

  Future<void> fetchPackages() async {
    if (state.status == CubitStates.loading) return;
    emit(state.copyWith(status: CubitStates.loading));
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.chatDurationExtensions,
      );
      final data = ChatDurationPackagesResponse.fromJson(response);
      emit(state.copyWith(
        status: CubitStates.success,
        packages: data.packages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CubitStates.failure,
        error: e.toString(),
      ));
    }
  }
}
