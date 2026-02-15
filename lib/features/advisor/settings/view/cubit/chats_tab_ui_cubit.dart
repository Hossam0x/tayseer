import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_service.dart';

class ChatsTabUiState {
  final String? currentUserId;
  final bool isLoading;

  const ChatsTabUiState({this.currentUserId, this.isLoading = true});
}

class ChatsTabUiCubit extends Cubit<ChatsTabUiState> {
  ChatsTabUiCubit() : super(const ChatsTabUiState());

  Future<void> loadCurrentUserId() async {
    try {
      final userId = await UserService.getCurrentUserId();
      emit(ChatsTabUiState(currentUserId: userId, isLoading: false));
    } catch (e) {
      // Handle error gracefully, maybe just stop loading
      emit(const ChatsTabUiState(isLoading: false));
    }
  }
}
