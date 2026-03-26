import 'package:tayseer/features/user/marriage/view_model/marriage_event_bus.dart';
import 'package:tayseer/features/user/marriage_filter/repo/marriage_filter_repo.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterCubit extends Cubit<MarriageFilterState> {
  MarriageFilterCubit({MarriageFilterRepo? repository})
    : _repo = repository ?? getIt<MarriageFilterRepo>(),
      super(const MarriageFilterState());

  final MarriageFilterRepo _repo;

  static const Map<String, String> _keyMapping = {
    'maritalStatus': 'socialStatus',
    'religiousCommitment': 'religiousCommitment',
    'goalMarry': 'marriageIntentions',
    'goalEngagment': 'engagment',
    'goalTravel': 'intendTravelAbroad',
    'goalChildren': 'familyAcceptance',
    'educationLevel': 'educationLevel',
    'smoker': 'smoker',
    'wearHijab': 'wearHijab',
    'job': 'job',
    'country': 'country',
    'nationality': 'nationality',
    'isVerified': 'isVerified',
    'isNew': 'isNew',
    'imageBlur': 'imageBlur',
    'goldAccount': 'goldAccount',
    'hobbies': 'hobbies',
    'height': 'height',
  };

  static const Map<String, bool> _imageBlurValueMap = {
    'visible_photo': false,
    'hidden_photo': true,
  };

  void updateAgeRange(RangeValues values) =>
      emit(state.copyWith(ageRange: values));

  void updateField(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(state.selectedFilters);
    newFilters[key] = value;
    emit(state.copyWith(selectedFilters: newFilters));
  }

  void resetFilters() => emit(const MarriageFilterState());

  Future<void> sendMarriageFilter() async {
    if (state.marriageFilterStatus == CubitStates.loading) return;
    emit(
      state.copyWith(
        marriageFilterStatus: CubitStates.loading,
        errorMessage: null,
      ),
    );

    final filtersToSend = _prepareFiltersForBackend();
    debugPrint('🚀 Sending to backend: $filtersToSend');

    final result = await _repo.marriageFilter(filters: filtersToSend);

    result.fold(
      (failure) => emit(
        state.copyWith(
          marriageFilterStatus: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(marriageFilterStatus: CubitStates.success));

        // ✅ بعت الفلاتر للـ MarriageCubit
        MarriageEventBus.instance.applyFilter(filtersToSend);

        // ✅ حول لتاب الزواج لو المستخدم كان في التفاعلات
        MarriageEventBus.instance.switchToMarriageTab();
      },
    );
  }

  Map<String, dynamic> _prepareFiltersForBackend() {
    final Map<String, dynamic> filters = {};

    filters['minAge'] = state.ageRange.start.round();
    filters['maxAge'] = state.ageRange.end.round();

    state.selectedFilters.forEach((key, value) {
      if (value == null) return;
      if (value == 'no_preference') return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List &&
          (value.isEmpty || value.every((e) => e == 'no_preference')))
        return;

      final apiKey = _keyMapping[key] ?? key;

      // ── imageBlur: visible/hidden → bool ──
      if (key == 'imageBlur' && value is String) {
        final boolValue = _imageBlurValueMap[value];
        if (boolValue != null) filters[apiKey] = boolValue;
        return;
      }

      // ── isVerified: yes→true | no→false ──
      if (key == 'isVerified' && value is String) {
        if (value == 'yes') {
          filters[apiKey] = true;
        } else if (value == 'no') {
          filters[apiKey] = false;
        }
        return;
      }

      // ── كل الباقي يتبعت كما هو ──
      filters[apiKey] = value;
    });

    debugPrint('📦 Final filters: $filters');
    return filters;
  }
}
