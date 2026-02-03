import 'package:equatable/equatable.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterState extends Equatable {
  final RangeValues ageRange;
  final Map<String, dynamic> selectedFilters;

  const MarriageFilterState({
    this.ageRange = const RangeValues(22, 35),
    this.selectedFilters = const {},
  });

  MarriageFilterState copyWith({
    RangeValues? ageRange,
    Map<String, dynamic>? selectedFilters,
  }) {
    return MarriageFilterState(
      ageRange: ageRange ?? this.ageRange,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }

  @override
  List<Object?> get props => [ageRange, selectedFilters];
}
