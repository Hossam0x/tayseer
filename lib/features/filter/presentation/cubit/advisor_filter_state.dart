import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AdvisorFilterState extends Equatable {
  final RangeValues priceRange;
  final String? selectedExperience;
  final int selectedRating;
  final List<String> selectedLanguages;
  final List<String> selectedBadges;
  final DateTime selectedDate;

  const AdvisorFilterState({
    required this.priceRange,
    this.selectedExperience,
    required this.selectedRating,
    required this.selectedLanguages,
    required this.selectedBadges,
    required this.selectedDate,
  });

  factory AdvisorFilterState.initial() {
    return AdvisorFilterState(
      priceRange: const RangeValues(22, 75),
      selectedExperience: null,
      selectedRating: 0,
      selectedLanguages: const ['arabic'],
      selectedBadges: const [
        'expert',
        'fast_response',
        'influencer',
        'trusted',
      ],
      selectedDate: DateTime.now(),
    );
  }

  AdvisorFilterState copyWith({
    RangeValues? priceRange,
    String? selectedExperience,
    int? selectedRating,
    List<String>? selectedLanguages,
    List<String>? selectedBadges,
    DateTime? selectedDate,
  }) {
    return AdvisorFilterState(
      priceRange: priceRange ?? this.priceRange,
      selectedExperience: selectedExperience,
      selectedRating: selectedRating ?? this.selectedRating,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      selectedBadges: selectedBadges ?? this.selectedBadges,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  AdvisorFilterState reset() {
    return AdvisorFilterState.initial();
  }

  @override
  List<Object?> get props => [
    priceRange,
    selectedExperience,
    selectedRating,
    selectedLanguages,
    selectedBadges,
    selectedDate,
  ];
}
