// lib/features/filter/presentation/cubit/advisor_filter_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/filter/data/advisor_filter_repo/advisor_filter_repo.dart';
import '../../data/models/advisor_filter_request_model.dart';
import 'advisor_filter_state.dart';

class AdvisorFilterCubit extends Cubit<AdvisorFilterState> {
  final AdvisorFilterRepo _repo;

  AdvisorFilterCubit({AdvisorFilterRepo? repo})
    : _repo = repo ?? AdvisorFilterRepoImpl(),
      super(AdvisorFilterState.initial());

  // ─── UI updates ───────────────────────────────────────────────────────────

  void updatePriceRange(RangeValues values) =>
      emit(state.copyWith(priceRange: values));

  void updateExperience(String? experience) =>
      emit(state.copyWith(selectedExperience: experience));

  void toggleRating(int rating) => emit(
    state.copyWith(selectedRating: state.selectedRating == rating ? 0 : rating),
  );

  void toggleLanguage(String language) {
    final updated = List<String>.from(state.selectedLanguages);
    updated.contains(language)
        ? updated.remove(language)
        : updated.add(language);
    emit(state.copyWith(selectedLanguages: updated));
  }

  void toggleBadge(String badge) {
    final updated = List<String>.from(state.selectedBadges);
    updated.contains(badge) ? updated.remove(badge) : updated.add(badge);
    emit(state.copyWith(selectedBadges: updated));
  }

  void updateDate(DateTime date) => emit(state.copyWith(selectedDate: date));

  void previousMonth(DateTime current) {
    final today = DateTime.now();
    final prev = DateTime(current.year, current.month - 1, 1);
    final isCurrentMonth = prev.year == today.year && prev.month == today.month;
    emit(
      state.copyWith(
        selectedDate: isCurrentMonth
            ? DateTime(today.year, today.month, today.day)
            : prev,
      ),
    );
  }

  void nextMonth(DateTime current) {
    final today = DateTime.now();
    final next = DateTime(current.year, current.month + 1, 1);
    final isCurrentMonth = next.year == today.year && next.month == today.month;
    emit(
      state.copyWith(
        selectedDate: isCurrentMonth
            ? DateTime(today.year, today.month, today.day)
            : next,
      ),
    );
  }

  void clearFilters() => emit(AdvisorFilterState.initial());

  // ─── Apply ────────────────────────────────────────────────────────────────

  Future<void> applyFilters(BuildContext context) async {
    emit(state.copyWith(status: AdvisorFilterStatus.loading));

    final request = AdvisorFilterRequestModel(
      priceMin: state.priceRange.start,
      priceMax: state.priceRange.end,
      yearsOfExperience: _parseExperience(state.selectedExperience),
      rating: state.selectedRating > 0 ? state.selectedRating.toDouble() : null,
      language: state.selectedLanguages.isNotEmpty
          ? state.selectedLanguages.first
          : null,
      // ✅ تحويل صح: Saturday=0, Sunday=1, Monday=2, ..., Friday=6
      dayOfWeek: _convertDayOfWeek(state.selectedDate.weekday),
      page: 1,
    );

    emit(state.copyWith(status: AdvisorFilterStatus.success));
    Navigator.pop(context, request);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// تحويل DateTime.weekday للـ format المطلوب من الـ API
  ///
  /// DateTime.weekday → Monday=1, Tuesday=2, ..., Saturday=6, Sunday=7
  /// المطلوب          → Saturday=0, Sunday=1, Monday=2, ..., Friday=6
  ///
  /// ┌──────────┬─────────┬─────────┐
  /// │ Dart val │   Day   │ API val │
  /// ├──────────┼─────────┼─────────┤
  /// │    6     │ Saturday│    0    │
  /// │    7     │ Sunday  │    1    │
  /// │    1     │ Monday  │    2    │
  /// │    2     │ Tuesday │    3    │
  /// │    3     │Wednesday│    4    │
  /// │    4     │Thursday │    5    │
  /// │    5     │ Friday  │    6    │
  /// └──────────┴─────────┴─────────┘
  int _convertDayOfWeek(int dartWeekday) {
    const Map<int, int> dayMap = {
      6: 0, // Saturday
      7: 1, // Sunday
      1: 2, // Monday
      2: 3, // Tuesday
      3: 4, // Wednesday
      4: 5, // Thursday
      5: 6, // Friday
    };
    return dayMap[dartWeekday] ?? 0;
  }

  /// ✅ value من الـ dropdown رقم صريح ("1","3","5","10") → int
  int? _parseExperience(String? experience) {
    if (experience == null || experience.isEmpty) return null;
    return int.tryParse(experience);
  }
}
