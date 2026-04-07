import 'package:tayseer/features/user/my_space/data/model/advisor_offering_model.dart';
import 'package:tayseer/my_import.dart';

class BookingState {
  final CubitStates getOfferingsState;
  final String? errorMessage;
  final List<AdvisorOfferingModel> offerings;

  BookingState({
    this.getOfferingsState = CubitStates.initial,
    this.errorMessage,
    this.offerings = const [],
  });

  BookingState copyWith({
    CubitStates? getOfferingsState,
    String? errorMessage,
    List<AdvisorOfferingModel>? offerings,
  }) {
    return BookingState(
      getOfferingsState: getOfferingsState ?? this.getOfferingsState,
      errorMessage: errorMessage ?? this.errorMessage,
      offerings: offerings ?? this.offerings,
    );
  }
}
