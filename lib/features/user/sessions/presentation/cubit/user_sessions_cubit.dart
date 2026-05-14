import 'package:tayseer/features/user/sessions/data/repo/user_sessions_repo.dart';
import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_state.dart';
import 'package:tayseer/my_import.dart';

class UserSessionsCubit extends Cubit<UserSessionsState> {
  final UserSessionsRepo _repo;
  static const int _pageSize = 10;

  UserSessionsCubit(this._repo) : super(const UserSessionsState()) {
    fetchSessions();
  }

  Future<void> fetchSessions({bool refresh = false}) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        fetchState: CubitStates.loading,
        sessions: refresh ? [] : state.sessions,
        currentPage: 1,
      ),
    );

    final result = await _repo.getUserSessions(
      page: 1,
      limit: _pageSize,
      status: state.selectedStatus,
      paymentStatus: state.selectedPaymentStatus,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          fetchState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          fetchState: CubitStates.success,
          sessions: response.data.sessions,
          currentPage: response.data.pagination.currentPage,
          totalPages: response.data.pagination.totalPages,
          hasMore:
              response.data.pagination.currentPage <
              response.data.pagination.totalPages,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (isClosed) return;
    if (!state.hasMore) return;
    if (state.loadMoreState == CubitStates.loading) return;

    emit(state.copyWith(loadMoreState: CubitStates.loading));

    final nextPage = state.currentPage + 1;

    final result = await _repo.getUserSessions(
      page: nextPage,
      limit: _pageSize,
      status: state.selectedStatus,
      paymentStatus: state.selectedPaymentStatus,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          loadMoreState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          loadMoreState: CubitStates.success,
          sessions: [...state.sessions, ...response.data.sessions],
          currentPage: response.data.pagination.currentPage,
          totalPages: response.data.pagination.totalPages,
          hasMore:
              response.data.pagination.currentPage <
              response.data.pagination.totalPages,
        ),
      ),
    );
  }

  void selectStatus(String? status) {
    final newStatus = state.selectedStatus == status ? null : status;
    emit(
      state.copyWith(selectedStatus: newStatus, clearStatus: newStatus == null),
    );
    _fetchWithCurrentFilters();
  }

  void selectPaymentStatus(String? paymentStatus) {
    final newPayment = state.selectedPaymentStatus == paymentStatus
        ? null
        : paymentStatus;
    emit(
      state.copyWith(
        selectedPaymentStatus: newPayment,
        clearPaymentStatus: newPayment == null,
      ),
    );
    _fetchWithCurrentFilters();
  }

  void clearFilters() {
    emit(state.copyWith(clearStatus: true, clearPaymentStatus: true));
    _fetchWithCurrentFilters();
  }

  Future<void> _fetchWithCurrentFilters() async {
    if (isClosed) return;

    emit(
      state.copyWith(
        fetchState: CubitStates.loading,
        sessions: [],
        currentPage: 1,
      ),
    );

    final result = await _repo.getUserSessions(
      page: 1,
      limit: _pageSize,
      status: state.selectedStatus,
      paymentStatus: state.selectedPaymentStatus,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          fetchState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          fetchState: CubitStates.success,
          sessions: response.data.sessions,
          currentPage: response.data.pagination.currentPage,
          totalPages: response.data.pagination.totalPages,
          hasMore:
              response.data.pagination.currentPage <
              response.data.pagination.totalPages,
        ),
      ),
    );
  }
}
