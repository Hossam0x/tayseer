import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/advisor_filter_request_model.dart';
import 'advisor_filter_state.dart';

class AdvisorFilterCubit extends Cubit<AdvisorFilterState> {
  AdvisorFilterCubit() : super(AdvisorFilterState.initial());

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
      yearsOfExperience: _parseExperience(
        state.selectedExperience,
      ), // ✅ String?
      rating: state.selectedRating > 0 ? state.selectedRating.toDouble() : null,
      language: state.selectedLanguages.isNotEmpty
          ? state.selectedLanguages.first
          : null,
      dayOfWeek: _convertDayOfWeek(state.selectedDate.weekday),
      page: 1,
    );

    emit(state.copyWith(status: AdvisorFilterStatus.success));
    Navigator.pop(context, request);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  int _convertDayOfWeek(int dartWeekday) {
    const Map<int, int> dayMap = {
      7: 0, // Sunday  → 0
      1: 1, // Monday  → 1
      2: 2, // Tuesday → 2
      3: 3, // Wednesday → 3
      4: 4, // Thursday → 4
      5: 5, // Friday  → 5
      6: 6, // Saturday → 6
    };
    return dayMap[dartWeekday] ?? 0;
  }

  String? _parseExperience(String? experience) {
    // experience هنا = '1', '3', '5', '10' (value من الـ chip)
    const map = {
      '1': 'experience_0_2', // ✅ نفس key التسجيل
      '3': 'experience_2_5',
      '5': 'experience_5_10',
      '10': 'experience_10_plus',
    };
    return experience == null ? null : map[experience];
  }
}
