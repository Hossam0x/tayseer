import 'package:tayseer/features/user/my_tickets_event/repo/my_tickets_repo.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_state.dart';
import 'package:tayseer/my_import.dart';

class MyTicketCubit extends Cubit<MyTicketState> {
  MyTicketCubit(this._repo) : super(const MyTicketState());

  final MyTicketsRepo _repo;

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

          emit(
            state.copyWith(
              myReservationsState: CubitStates.initial,
              errorMessage: null,
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

          emit(state.copyWith(myReservationsState: CubitStates.initial));
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

          emit(
            state.copyWith(
              reservationDetailsState: CubitStates.initial,
              errorMessage: null,
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
