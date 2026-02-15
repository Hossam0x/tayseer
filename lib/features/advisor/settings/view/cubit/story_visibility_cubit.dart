import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/story_visibility_repository.dart';
import 'package:tayseer/my_import.dart';
import 'story_visibility_state.dart';

class StoryVisibilityCubit extends Cubit<StoryVisibilityState> {
  final StoryVisibilityRepository _repository;
  final Debouncer<String> _searchDebouncer;

  StoryVisibilityCubit(this._repository)
    : _searchDebouncer = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '',
      ),
      super(StoryVisibilityState.initial()) {
    _initialize();
  }

  void _initialize() {
    // إعداد listener للبحث المتباطئ
    _searchDebouncer.values.listen((searchQuery) {
      loadRestrictedUsers(searchQuery: searchQuery);
    });

    // تحميل البيانات الأولية
    loadRestrictedUsers();
  }

  Future<void> loadRestrictedUsers({String searchQuery = ''}) async {
    emit(
      state.copyWith(
        state: CubitStates.loading,
        isLoading: true,
        searchQuery: searchQuery,
      ),
    );

    final result = await _repository.getRestrictedUsers(search: searchQuery);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            isLoading: false,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            state: CubitStates.success,
            users: response.restrictedUsers,
            isLoading: false,
          ),
        );
      },
    );
  }

  void updateSearchQuery(String searchQuery) {
    emit(state.copyWith(searchQuery: searchQuery));
    _searchDebouncer.setValue(searchQuery);
  }

  void toggleUserSelection(String userId) {
    final updatedUsers = state.users.map((user) {
      if (user.userId == userId) {
        return user.copyWith(isSelected: !user.isSelected);
      }
      return user;
    }).toList();

    emit(state.copyWith(users: updatedUsers));
  }

  void selectAllUsers() {
    final allSelected =
        !state.hasSelections ||
        state.selectedUsers.length != state.users.length;

    final updatedUsers = state.users.map((user) {
      return user.copyWith(isSelected: allSelected);
    }).toList();

    emit(state.copyWith(users: updatedUsers));
  }

  Future<void> unrestrictSelectedUsers() async {
    if (state.selectedUserIds.isEmpty || state.isUnrestricting) return;

    emit(
      state.copyWith(
        isUnrestricting: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _repository.unrestrictUsers(
      userIds: state.selectedUserIds,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.message, isUnrestricting: false),
        );
      },
      (response) {
        emit(
          state.copyWith(
            successMessage: 'story_unrestrict_success',
            isUnrestricting: false,
          ),
        );
        loadRestrictedUsers(); // Assuming loadBlockedUsers() should be loadRestrictedUsers() based on context
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  void clearSuccess() {
    if (state.successMessage != null) {
      emit(state.copyWith(successMessage: null));
    }
  }

  @override
  Future<void> close() {
    // _searchDebouncer.dispose();
    return super.close();
  }
}
