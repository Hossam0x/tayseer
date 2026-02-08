import 'package:equatable/equatable.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterState extends Equatable {
  final CubitStates marriageFilterStatus;
  final RangeValues ageRange;
  final Map<String, dynamic> selectedFilters;
  final String? errorMessage;

  const MarriageFilterState({
    this.marriageFilterStatus = CubitStates.initial,
    this.ageRange = const RangeValues(22, 35),
    this.selectedFilters = const {},
    this.errorMessage,
  });

  MarriageFilterState copyWith({
    CubitStates? marriageFilterStatus,
    RangeValues? ageRange,
    Map<String, dynamic>? selectedFilters,
    String? errorMessage,
  }) {
    return MarriageFilterState(
      marriageFilterStatus: marriageFilterStatus ?? this.marriageFilterStatus,
      ageRange: ageRange ?? this.ageRange,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    marriageFilterStatus,
    ageRange,
    selectedFilters,
    errorMessage,
  ];
}
