import 'package:tayseer/features/user/my_tickets_event/repo/my_tickets_repo.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_state.dart';
import 'package:tayseer/my_import.dart';

class MyTicketCubit extends Cubit<MyTicketState> {
  MyTicketCubit() : super(const MyTicketState());

  MyTicketsRepo get _repo => getIt<MyTicketsRepo>();

  Future<void> getMyReservations() async {
    emit(state.copyWith(myReservationsState: CubitStates.loading));

    try {
      final response = await _repo.getMyReservations();

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              myReservationsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              myReservationsState: CubitStates.success,
              myReservations: data,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          myReservationsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getReservationDetails(String id) async {
    emit(state.copyWith(reservationDetailsState: CubitStates.loading));

    try {
      final response = await _repo.getReservationDetails(id);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              reservationDetailsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              reservationDetailsState: CubitStates.success,
              reservationDetails: data,
            ),
          );

          emit(state.copyWith(reservationDetailsState: CubitStates.initial));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          reservationDetailsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
