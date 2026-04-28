import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';

enum UpdateOfferingsStep { selectCountry, addSessions, summary }

class UpdateOfferingsState extends Equatable {
  final CubitStates loadState;
  final CubitStates saveState;
  final String? errorMessage;
  final String? successMessage;

  // الـ step الحالي في الـ flow
  final UpdateOfferingsStep step;

  // الدولة المختارة حالياً
  final String? selectedCountryKey;
  final String? selectedCountryFlag;

  // الجلسات المؤقتة للدولة الحالية
  final List<OfferingItemModel> currentOfferings;

  // الملخص النهائي (كل الدول)
  final List<CountryOfferingsModel> summaryList;

  // بيانات الاشتراك من الـ GET
  final String subscriptionType;
  final double sessionsAppInterestPercentage;

  const UpdateOfferingsState({
    this.loadState = CubitStates.initial,
    this.saveState = CubitStates.initial,
    this.errorMessage,
    this.successMessage,
    this.step = UpdateOfferingsStep.selectCountry,
    this.selectedCountryKey,
    this.selectedCountryFlag,
    this.currentOfferings = const [],
    this.summaryList = const [],
    this.subscriptionType = 'free',
    this.sessionsAppInterestPercentage = 25.0,
  });

  bool get isSaving => saveState == CubitStates.loading;
  bool get isLoading => loadState == CubitStates.loading;
  bool get hasSummaryData => summaryList.isNotEmpty;

  Set<String> get addedCountryKeys =>
      summaryList.map((c) => c.countryKey).toSet();

  UpdateOfferingsState copyWith({
    CubitStates? loadState,
    CubitStates? saveState,
    String? errorMessage,
    String? successMessage,
    UpdateOfferingsStep? step,
    String? selectedCountryKey,
    String? selectedCountryFlag,
    List<OfferingItemModel>? currentOfferings,
    List<CountryOfferingsModel>? summaryList,
    String? subscriptionType,
    double? sessionsAppInterestPercentage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedCountry = false,
  }) {
    return UpdateOfferingsState(
      loadState: loadState ?? this.loadState,
      saveState: saveState ?? this.saveState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      step: step ?? this.step,
      selectedCountryKey: clearSelectedCountry
          ? null
          : (selectedCountryKey ?? this.selectedCountryKey),
      selectedCountryFlag: clearSelectedCountry
          ? null
          : (selectedCountryFlag ?? this.selectedCountryFlag),
      currentOfferings: currentOfferings ?? this.currentOfferings,
      summaryList: summaryList ?? this.summaryList,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      sessionsAppInterestPercentage:
          sessionsAppInterestPercentage ?? this.sessionsAppInterestPercentage,
    );
  }

  @override
  List<Object?> get props => [
    loadState,
    saveState,
    errorMessage,
    successMessage,
    step,
    selectedCountryKey,
    selectedCountryFlag,
    currentOfferings,
    summaryList,
    subscriptionType,
    sessionsAppInterestPercentage,
  ];
}
