import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterCubit extends Cubit<MarriageFilterState> {
  MarriageFilterCubit() : super(const MarriageFilterState());

  void updateAgeRange(RangeValues values) =>
      emit(state.copyWith(ageRange: values));

  void updateField(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(state.selectedFilters);
    newFilters[key] = value;
    emit(state.copyWith(selectedFilters: newFilters));
  }

  void resetFilters() => emit(const MarriageFilterState());
}
