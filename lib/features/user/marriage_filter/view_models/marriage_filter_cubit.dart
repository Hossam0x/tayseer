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

    final filtersToSend = _prepareFiltersForBackend();
    debugPrint('🚀 Sending to backend: $filtersToSend');

    final result = await _repo.marriageFilter(filters: filtersToSend);
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

  Map<String, dynamic> _prepareFiltersForBackend() {
    final Map<String, dynamic> filters = {};

    // ✅ minAge و maxAge دايماً
    filters['minAge'] = state.ageRange.start.round();
    filters['maxAge'] = state.ageRange.end.round();

    // ✅ باقي الفلاتر بس لو ليها قيمة فعلية
    state.selectedFilters.forEach((key, value) {
      // ❌ سيبها لو "لا يوجد تفضيل" أو null أو فاضية
      if (value == null) return;
      if (value == 'لا يوجد تفضيل') return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List && value.isEmpty) return;

      // ✅ ضفها لو قيمة حقيقية
      filters[key] = value;
    });

    return filters;
  }
}
