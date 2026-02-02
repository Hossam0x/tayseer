import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageCubit extends Cubit<MarriageState> {
  MarriageCubit({MarriageRepository? repository})
    : _repo = repository ?? getIt<MarriageRepository>(),
      super(const MarriageState());
  final MarriageRepository _repo;

  Future<void> fetchMarriageProfile() async {
    emit(state.copyWith(state: CubitStates.loading, errorMessage: null));
    final result = await _repo.getMarriageProfile();
    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) =>
          emit(state.copyWith(state: CubitStates.success, profile: profile)),
    );
  }
}
