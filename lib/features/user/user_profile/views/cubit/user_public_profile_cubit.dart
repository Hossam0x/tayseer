import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileCubit extends Cubit<UserPublicProfileState> {
  final UserPublicProfileRepository _repository;
  final String? userId;
  final UserProfileModel? initialProfile; // ⭐ إضافة

  UserPublicProfileCubit(
    this._repository, {
    this.userId,
    this.initialProfile, // ⭐ إضافة
  }) : super(const UserPublicProfileState()) {
    if (initialProfile != null) {
      // ⭐ إذا كان هناك بيانات أولية، استخدمها مباشرة
      emit(state.copyWith(state: CubitStates.success, profile: initialProfile));
    } else if (userId != null) {
      // ⭐ إذا لم يكن هناك بيانات أولية، جلبها من الـ API
      fetchProfile();
    }
  }

  // ⭐ تحديث: دالة تهيئة بالبيانات
  void initializeWithProfile(UserProfileModel profile) {
    emit(state.copyWith(state: CubitStates.success, profile: profile));
  }

  Future<void> fetchProfile() async {
    if (userId == null) return;
    if (state.state == CubitStates.loading) return;

    emit(state.copyWith(state: CubitStates.loading, errorMessage: null));

    final result = await _repository.getUserPublicProfile(userId!);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          state: CubitStates.success,
          profile: profile,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> deleteUserAccount() async {
    if (state.isLoadingDelete) return;

    emit(state.copyWith(isLoadingDelete: true));

    final result = await _repository.deleteUserAccount();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingDelete: false, errorMessage: failure.message),
      ),
      (message) => emit(state.copyWith(isLoadingDelete: false)),
    );
  }

  void refresh() {
    fetchProfile();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
