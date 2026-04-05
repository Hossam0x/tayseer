import 'package:tayseer/features/shared/settings/cubit/account_management_state.dart';
import 'package:tayseer/features/shared/settings/repositories/account_management_repository.dart';
import 'package:tayseer/my_import.dart';

/// Shared account management cubit used by both advisor and user features.
/// Inject the appropriate [AccountManagementRepository] implementation.
class AccountManagementCubit extends Cubit<AccountManagementState> {
  final AccountManagementRepository _repository;

  AccountManagementCubit(this._repository)
    : super(const AccountManagementState());

  Future<void> suspendAccount() async {
    emit(
      state.copyWith(
        state: CubitStates.loading,
        operation: AccountOperation.suspend,
        errorMessage: null,
      ),
    );
    final result = await _repository.suspendAccount();
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          operation: AccountOperation.suspend,
        ),
      ),
      (_) => emit(
        state.copyWith(
          state: CubitStates.success,
          operation: AccountOperation.suspend,
          successMessage: 'account_suspended_success',
        ),
      ),
    );
  }

  Future<void> deleteAccount() async {
    emit(
      state.copyWith(
        state: CubitStates.loading,
        operation: AccountOperation.delete,
        errorMessage: null,
      ),
    );
    final result = await _repository.deleteAccount();
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          operation: AccountOperation.delete,
        ),
      ),
      (_) => emit(
        state.copyWith(
          state: CubitStates.success,
          operation: AccountOperation.delete,
          successMessage: 'account_deleted_success',
        ),
      ),
    );
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
  void clearSuccess() => emit(state.copyWith(successMessage: null));
}
