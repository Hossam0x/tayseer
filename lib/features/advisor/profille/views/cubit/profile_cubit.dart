import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/my_import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final HomeRepository _homeRepository;
  final int _pageSize = 10;

  ProfileCubit(this._profileRepository, this._homeRepository)
    : super(const ProfileState()) {
    _initializeProfile();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 INITIALIZE PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> _initializeProfile() async {
    await Future.wait([fetchProfile(), fetchPosts()]);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchProfile() async {
    if (state.profileState == CubitStates.loading) return;

    emit(state.copyWith(profileState: CubitStates.loading));

    final result = await _profileRepository.getAdvisorProfile();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          profileState: CubitStates.failure,
          profileErrorMessage: failure.message,
        ),
      ),
      (profileModel) => emit(
        state.copyWith(
          profileState: CubitStates.success,
          profile: profileModel,
          profileErrorMessage: null, // تنظيف رسالة الخطأ عند النجاح
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH POSTS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchPosts({bool loadMore = false}) async {
    if (loadMore) {
      // لا تسمح بتحميل المزيد إذا كان التحميل جارياً أو لا يوجد المزيد
      if (state.isLoadingMore || !state.hasMore) return;
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _homeRepository.fetchPosts(page: nextPage);
      if (isClosed) return;
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoadingMore: false,
              postsErrorMessage: failure.message,
            ),
          );
        },
        (newPosts) {
          final updatedList = [...state.posts, ...newPosts];
          emit(
            state.copyWith(
              posts: updatedList,
              currentPage: nextPage,
              hasMore: newPosts.length >= _pageSize,
              isLoadingMore: false,
              postsErrorMessage: null,
            ),
          );
        },
      );
    } else {
      if (isClosed) return;
      // التحميل الأولي
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          postsErrorMessage: null,
        ),
      );

      final result = await _homeRepository.fetchPosts(page: 1);
      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              postsState: CubitStates.failure,
              postsErrorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              postsState: CubitStates.success,
              posts: postsList,
              currentPage: 1,
              hasMore: postsList.length >= _pageSize,
              postsErrorMessage: null,
            ),
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH ALL DATA
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await Future.wait([fetchProfile(), fetchPosts(loadMore: false)]);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 UPDATE PROFILE PICTURE (إذا كان مطلوباً)
  // ═══════════════════════════════════════════════════════════
  void updateProfileImage(String newImageUrl) {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(image: newImageUrl);
      if (isClosed) return;
      emit(state.copyWith(profile: updatedProfile));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERRORS
  // ═══════════════════════════════════════════════════════════
  void clearProfileError() {
    if (isClosed) return;
    emit(state.copyWith(profileErrorMessage: null));
  }

  void clearPostsError() {
    if (isClosed) return;
    emit(state.copyWith(postsErrorMessage: null));
  }
}
