
// ════════════════════════════════════════════════════════
// advisor_filter_state.dart
// ════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AdvisorFilterStatus { initial, loading, success, failure }

// ✅ Sentinel — للتفريق بين "مش اتبعتش" و "اتبعتلها null صريح"
const Object _sentinel = Object();

class AdvisorFilterState extends Equatable {
  final RangeValues priceRange;
  final String? selectedExperience;
  final int selectedRating;
  final List<String> selectedLanguages;
  final List<String> selectedBadges;
  final DateTime selectedDate;
  final AdvisorFilterStatus status;
  final String? errorMessage;

  const AdvisorFilterState({
    required this.priceRange,
    this.selectedExperience,
    required this.selectedRating,
    required this.selectedLanguages,
    required this.selectedBadges,
    required this.selectedDate,
    this.status = AdvisorFilterStatus.initial,
    this.errorMessage,
  });

  // ✅ فاضي تماماً — مفيش اختيارات افتراضية
  factory AdvisorFilterState.initial() => AdvisorFilterState(
        priceRange: const RangeValues(0, 100),
        selectedExperience: null,
        selectedRating: 0,
        selectedLanguages: const [],
        selectedBadges: const [],
        selectedDate: DateTime.now(),
      );

  bool get isLoading => status == AdvisorFilterStatus.loading;
bool get isFilterComplete =>
    selectedExperience != null &&   // خبرة اتاختارت
    selectedRating != 0 &&          // رأي اتاختار
    selectedLanguages.isNotEmpty && // لغة واحدة على الأقل
    selectedBadges.isNotEmpty &&    // شارة واحدة على الأقل
    priceRange.start != priceRange.end;
  AdvisorFilterState copyWith({
    RangeValues? priceRange,
    // ✅ Object? بدل String? عشان الـ sentinel يشتغل
    Object? selectedExperience = _sentinel,
    int? selectedRating,
    List<String>? selectedLanguages,
    List<String>? selectedBadges,
    DateTime? selectedDate,
    AdvisorFilterStatus? status,
    String? errorMessage,
  }) {
    return AdvisorFilterState(
      priceRange: priceRange ?? this.priceRange,
      // ✅ لو _sentinel معناها مش اتغيرت، لو null معناها clear
      selectedExperience: selectedExperience == _sentinel
          ? this.selectedExperience
          : selectedExperience as String?,
      selectedRating: selectedRating ?? this.selectedRating,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      selectedBadges: selectedBadges ?? this.selectedBadges,
      selectedDate: selectedDate ?? this.selectedDate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        priceRange,
        selectedExperience,
        selectedRating,
        selectedLanguages,
        selectedBadges,
        selectedDate,
        status,
        errorMessage,
      ];
}
