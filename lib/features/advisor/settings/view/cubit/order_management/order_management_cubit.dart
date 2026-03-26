import '../../../../../../my_import.dart';
import '../../../data/repositories/order_management_repository.dart';
import 'order_management_state.dart';

class OrderManagementCubit extends Cubit<OrderManagementState> {
  final OrderManagementRepository _repository;

  OrderManagementCubit(this._repository) : super(const OrderManagementState());

  void selectAction(bool isAvailable) {
    emit(state.copyWith(isAvailable: isAvailable));
  }

  Future<void> updateAvailability() async {
    if (state.isAvailable == null) return;

    emit(state.copyWith(status: CubitStates.loading));

    final result = await _repository.changeAvailability(
      isAvailable: state.isAvailable!,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: CubitStates.success,
          successMessage: state.isAvailable!
              ? 'orders_receive_success'
              : 'orders_stop_success',
        ),
      ),
    );
  }
}
