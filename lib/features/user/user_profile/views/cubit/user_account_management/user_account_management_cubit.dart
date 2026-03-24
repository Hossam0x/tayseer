import 'package:tayseer/features/advisor/settings/view/cubit/account_management/account_management_state.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_account_management_repository.dart';
import 'package:tayseer/my_import.dart';

class UserAccountManagementCubit extends Cubit<AccountManagementState> {
  final UserAccountManagementRepository _repository;

  UserAccountManagementCubit(this._repository)
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
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            operation: AccountOperation.suspend,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            state: CubitStates.success,
            operation: AccountOperation.suspend,
            successMessage: 'تم إيقاف حسابك مؤقتاً بنجاح',
          ),
        );
      },
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
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            operation: AccountOperation.delete,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            state: CubitStates.success,
            operation: AccountOperation.delete,
            successMessage: 'تم حذف حسابك بنجاح',
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void clearSuccess() {
    emit(state.copyWith(successMessage: null));
  }
}
