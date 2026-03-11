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

    // ✅ لو رجعنا للشهر الحالي → نحط النهارده كـ selected
    // لو شهر مستقبلي → نحط أول يوم فيه
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

    // ✅ لو الشهر القادم هو الشهر الحالي (حالة نادرة) → النهارده
    // غير كده → أول يوم في الشهر الجديد
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

  // ─── Apply → log ──────────────────────────────────────────────────────────

  Future<void> applyFilters(BuildContext context) async {
    emit(state.copyWith(status: AdvisorFilterStatus.loading));

    final request = AdvisorFilterRequestModel(
      minPrice: state.priceRange.start,
      maxPrice: state.priceRange.end,
      experience: state.selectedExperience,
      rating: state.selectedRating > 0 ? state.selectedRating : null,
      languages: state.selectedLanguages,
      badges: state.selectedBadges,
      date: _formatDate(state.selectedDate),
    );

    final result = await _repo.filterAdvisors(request);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdvisorFilterStatus.failure,
          errorMessage: failure,
        ),
      ),
      (_) {
        emit(state.copyWith(status: AdvisorFilterStatus.success));
        Navigator.pop(context);
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
