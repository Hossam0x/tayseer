import 'package:tayseer/features/user/marriage_filter/repo/marriage_filter_repo.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterCubit extends Cubit<MarriageFilterState> {
  MarriageFilterCubit({MarriageFilterRepo? repository})
    : _repo = repository ?? getIt<MarriageFilterRepo>(),
      super(const MarriageFilterState());
  final MarriageFilterRepo _repo;

  void updateAgeRange(RangeValues values) =>
      emit(state.copyWith(ageRange: values));

  void updateField(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(state.selectedFilters);
    newFilters[key] = value;
    emit(state.copyWith(selectedFilters: newFilters));
  }

  void resetFilters() => emit(const MarriageFilterState());

  Future<void> sendMarriageFilter() async {
    emit(
      state.copyWith(
        marriageFilterStatus: CubitStates.loading,
        errorMessage: null,
      ),
    );
    final result = await _repo.marriageFilter(filters: state.selectedFilters);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            marriageFilterStatus: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(marriageFilterStatus: CubitStates.success));
      },
    );
  }
}
