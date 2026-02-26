import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'advisor_filter_state.dart';

class AdvisorFilterCubit extends Cubit<AdvisorFilterState> {
  AdvisorFilterCubit() : super(AdvisorFilterState.initial());

  void updatePriceRange(RangeValues values) {
    emit(state.copyWith(priceRange: values));
  }

  void updateExperience(String? experience) {
    emit(state.copyWith(selectedExperience: experience));
  }

  void toggleRating(int rating) {
    if (state.selectedRating == rating) {
      emit(state.copyWith(selectedRating: 0));
    } else {
      emit(state.copyWith(selectedRating: rating));
    }
  }

  void toggleLanguage(String language) {
    final List<String> current = List.from(state.selectedLanguages);
    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }
    emit(state.copyWith(selectedLanguages: current));
  }

  void toggleBadge(String badge) {
    final List<String> current = List.from(state.selectedBadges);
    if (current.contains(badge)) {
      current.remove(badge);
    } else {
      current.add(badge);
    }
    emit(state.copyWith(selectedBadges: current));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void nextMonth() {
    final next = DateTime(
      state.selectedDate.year,
      state.selectedDate.month + 1,
      1,
    );
    emit(state.copyWith(selectedDate: next));
  }

  void previousMonth() {
    final prev = DateTime(
      state.selectedDate.year,
      state.selectedDate.month - 1,
      1,
    );
    emit(state.copyWith(selectedDate: prev));
  }

  void clearFilters() {
    emit(AdvisorFilterState.initial());
  }

  void applyFilters() {
    // Logic to apply filters
  }
}
