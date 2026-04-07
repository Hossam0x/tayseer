import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/booking/booking_state.dart';
import 'package:tayseer/my_import.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repo) : super(BookingState());

  final MySpaceRepo _repo;

  Future<void> getOfferings(String advisorId) async {
    emit(state.copyWith(getOfferingsState: CubitStates.loading));

    final response = await _repo.getOfferingsBooking(advisorId);

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            getOfferingsState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            getOfferingsState: CubitStates.success,
            offerings: data.data,
          ),
        );
      },
    );
  }
}
