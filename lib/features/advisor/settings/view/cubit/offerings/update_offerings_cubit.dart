import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/data/repository/offerings_repository.dart';
import 'package:tayseer/my_import.dart';
import 'update_offerings_state.dart';

class UpdateOfferingsCubit extends Cubit<UpdateOfferingsState> {
  final OfferingsRepository _repository;

  UpdateOfferingsCubit(this._repository) : super(const UpdateOfferingsState()) {
    loadExistingOfferings();
  }

  // ─────────────────────────────────────────────
  // Load existing offerings from backend
  // ─────────────────────────────────────────────
  Future<void> loadExistingOfferings() async {
    emit(state.copyWith(loadState: CubitStates.loading));

    final result = await _repository.getOfferings();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          loadState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) {
        final summaryList = response.data.entries.map((entry) {
          return CountryOfferingsModel(
            countryKey: entry.key,
            flagEmoji: _getFlagForCountryKey(entry.key),
            offerings: entry.value,
          );
        }).toList();

        // لو فيه بيانات → افتح على الـ summary مباشرة
        emit(
          state.copyWith(
            loadState: CubitStates.success,
            summaryList: summaryList,
            subscriptionType: response.subscriptionType,
            sessionsAppInterestPercentage:
                response.sessionsAppInterestPercentage,
            step: summaryList.isNotEmpty
                ? UpdateOfferingsStep.summary
                : UpdateOfferingsStep.selectCountry,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Step 1: Select Country
  // ─────────────────────────────────────────────
  void selectCountry({required String countryKey, required String flagEmoji}) {
    emit(
      state.copyWith(
        selectedCountryKey: countryKey,
        selectedCountryFlag: flagEmoji,
        currentOfferings: [],
        step: UpdateOfferingsStep.addSessions,
      ),
    );
  }

  // إضافة offerings لدولة موجودة في الـ summary
  void addToExistingCountry({
    required String countryKey,
    required String flagEmoji,
  }) {
    emit(
      state.copyWith(
        selectedCountryKey: countryKey,
        selectedCountryFlag: flagEmoji,
        currentOfferings: [],
        step: UpdateOfferingsStep.addSessions,
      ),
    );
  }

  void goBackToCountrySelection() {
    emit(
      state.copyWith(
        step: UpdateOfferingsStep.selectCountry,
        clearSelectedCountry: true,
        currentOfferings: [],
      ),
    );
  }

  void goBackToSummary() {
    emit(
      state.copyWith(
        step: UpdateOfferingsStep.summary,
        clearSelectedCountry: true,
        currentOfferings: [],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Step 2: Add Sessions
  // ─────────────────────────────────────────────
  void addOffering(OfferingItemModel offering) {
    final updated = List<OfferingItemModel>.from(state.currentOfferings)
      ..add(offering);
    emit(state.copyWith(currentOfferings: updated));
  }

  void removeOffering(int index) {
    final updated = List<OfferingItemModel>.from(state.currentOfferings)
      ..removeAt(index);
    emit(state.copyWith(currentOfferings: updated));
  }

  void saveCurrentOfferingsToSummary() {
    if (state.selectedCountryKey == null || state.currentOfferings.isEmpty) {
      return;
    }

    final updatedSummary = List<CountryOfferingsModel>.from(state.summaryList);

    final existingIndex = updatedSummary.indexWhere(
      (c) => c.countryKey == state.selectedCountryKey,
    );

    if (existingIndex != -1) {
      final existing = updatedSummary[existingIndex];
      updatedSummary[existingIndex] = existing.copyWith(
        offerings: [...existing.offerings, ...state.currentOfferings],
      );
    } else {
      updatedSummary.add(
        CountryOfferingsModel(
          countryKey: state.selectedCountryKey!,
          flagEmoji: state.selectedCountryFlag ?? '',
          offerings: List.from(state.currentOfferings),
        ),
      );
    }

    emit(
      state.copyWith(
        summaryList: updatedSummary,
        currentOfferings: [],
        step: UpdateOfferingsStep.summary,
        clearSelectedCountry: true,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Step 3: Summary
  // ─────────────────────────────────────────────
  void removeCountryFromSummary(int index) {
    final updated = List<CountryOfferingsModel>.from(state.summaryList)
      ..removeAt(index);
    emit(state.copyWith(summaryList: updated));
  }

  void removeOfferingFromSummary({
    required int countryIndex,
    required int offeringIndex,
  }) {
    final updated = List<CountryOfferingsModel>.from(state.summaryList);
    final country = updated[countryIndex];
    final updatedOfferings = List<OfferingItemModel>.from(country.offerings)
      ..removeAt(offeringIndex);

    if (updatedOfferings.isEmpty) {
      updated.removeAt(countryIndex);
    } else {
      updated[countryIndex] = country.copyWith(offerings: updatedOfferings);
    }
    emit(state.copyWith(summaryList: updated));
  }

  void goToAddAnotherCountry() {
    emit(
      state.copyWith(
        step: UpdateOfferingsStep.selectCountry,
        clearSelectedCountry: true,
        currentOfferings: [],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Submit all offerings to backend
  // ─────────────────────────────────────────────
  Future<void> submitOfferings() async {
    if (state.summaryList.isEmpty) return;

    emit(state.copyWith(saveState: CubitStates.loading));

    // بناء الـ body: Map<countryKey, List<offering>>
    final Map<String, dynamic> body = {};
    for (final country in state.summaryList) {
      body[country.countryKey] = country.offerings
          .map((o) => o.toJson())
          .toList();
    }

    final result = await _repository.setOfferings(body: body);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          saveState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          saveState: CubitStates.success,
          successMessage: 'offerings_saved_successfully',
        ),
      ),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void clearSuccess() => emit(state.copyWith(clearSuccess: true));

  // ─────────────────────────────────────────────
  // Helper
  // ─────────────────────────────────────────────
  String _getFlagForCountryKey(String key) {
    const flags = {
      'country_saudi': '🇸🇦',
      'country_egypt': '🇪🇬',
      'country_emirati': '🇦🇪',
      'country_kuwait': '🇰🇼',
      'country_qatar': '🇶🇦',
      'country_bahrain': '🇧🇭',
      'country_jordan': '🇯🇴',
      'country_palestine': '🇵🇸',
      'country_morocco': '🇲🇦',
      'country_tunisia': '🇹🇳',
    };
    return flags[key] ?? '🌍';
  }
}
