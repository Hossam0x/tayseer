import 'dart:developer';
import 'package:tayseer/my_import.dart';
part 'phone_edit_state.dart';

class PhoneEditCubit extends Cubit<PhoneEditState> {
  final ApiService _apiService;

  PhoneEditCubit() : _apiService = ApiService(Dio()), super(PhoneEditInitial());

  final List<Map<String, String>> countries = [
    {"name": "السعودية", "code": "+966", "flag": "🇸🇦"},
    {"name": "مصر", "code": "+20", "flag": "🇪🇬"},
    {"name": "الإمارات", "code": "+971", "flag": "🇦🇪"},
    {"name": "الكويت", "code": "+965", "flag": "🇰🇼"},
    {"name": "قطر", "code": "+974", "flag": "🇶🇦"},
    {"name": "عُمان", "code": "+968", "flag": "🇴🇲"},
    {"name": "البحرين", "code": "+973", "flag": "🇧🇭"},
    {"name": "الأردن", "code": "+962", "flag": "🇯🇴"},
    {"name": "لبنان", "code": "+961", "flag": "🇱🇧"},
    {"name": "العراق", "code": "+964", "flag": "🇮🇶"},
    {"name": "المغرب", "code": "+212", "flag": "🇲🇦"},
    {"name": "الجزائر", "code": "+213", "flag": "🇩🇿"},
    {"name": "تونس", "code": "+216", "flag": "🇹🇳"},
  ];

  void initializePhone(String initialPhone) {
    if (initialPhone.isNotEmpty) {
      for (var country in countries) {
        if (initialPhone.startsWith(country['code']!)) {
          emit(
            state.copyWith(
              selectedCountryCode: country['code']!,
              selectedCountryFlag: country['flag']!,
              selectedCountryName: country['name']!,
              phoneNumber: initialPhone.substring(country['code']!.length),
            ),
          );
          break;
        }
      }
    } else {
      emit(
        state.copyWith(
          selectedCountryCode: "+966",
          selectedCountryFlag: "🇸🇦",
          selectedCountryName: "السعودية",
        ),
      );
    }
    validatePhoneNumber();
  }

  void updateCountry(Map<String, String> country) {
    emit(
      state.copyWith(
        selectedCountryCode: country['code']!,
        selectedCountryFlag: country['flag']!,
        selectedCountryName: country['name']!,
      ),
    );
    validatePhoneNumber();
  }

  void updatePhoneNumber(String phone) {
    emit(state.copyWith(phoneNumber: phone));
    validatePhoneNumber();
  }

  void validatePhoneNumber() {
    String error = '';
    final phone = state.phoneNumber.trim();

    if (phone.isEmpty) {
      error = 'يرجى إدخال رقم الهاتف';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      error = 'يجب أن يحتوي الرقم على أرقام فقط';
    } else if (phone.length < 8) {
      error = 'رقم الهاتف قصير جداً';
    } else if (phone.length > 15) {
      error = 'رقم الهاتف طويل جداً';
    } else {
      // تحقق حسب رمز الدولة
      if (state.selectedCountryCode == "+966" && !phone.startsWith('5')) {
        error = 'يجب أن يبدأ الرقم السعودي بـ 5';
      } else if (state.selectedCountryCode == "+20" && !phone.startsWith('1')) {
        error = 'يجب أن يبدأ الرقم المصري بـ 1';
      }
    }

    emit(state.copyWith(phoneError: error));
  }

  Future<void> updatePhone() async {
    if (state.phoneNumber.isEmpty || state.phoneError.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        updatePhoneStatus: CubitStates.loading,
        errorMessage: '',
        successMessage: '',
      ),
    );

    try {
      final cleanedPhone = state.phoneNumber.replaceAll(RegExp(r'\D'), '');
      log('طلب تحديث الهاتف: ${state.selectedCountryCode}$cleanedPhone');

      final response = await _apiService.post(
        endPoint: '/user/update-phone-number',
        data: {'countryCode': state.selectedCountryCode, 'phone': cleanedPhone},
      );

      if (response['success'] == true) {
        final fullPhoneNumber = '${state.selectedCountryCode}$cleanedPhone';
        emit(
          state.copyWith(
            updatePhoneStatus: CubitStates.success,
            fullPhoneNumber: fullPhoneNumber,
            successMessage: 'تم إرسال رمز التحقق بنجاح',
            errorMessage: '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            updatePhoneStatus: CubitStates.failure,
            errorMessage: response['message'] ?? 'فشل تحديث رقم الهاتف',
          ),
        );
      }
    } on DioException catch (e) {
      final failure = ServerFailure.fromDioError(e);
      emit(
        state.copyWith(
          updatePhoneStatus: CubitStates.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updatePhoneStatus: CubitStates.failure,
          errorMessage: 'حدث خطأ غير متوقع',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: '', successMessage: ''));
  }

  void resetError() {
    emit(
      state.copyWith(
        updatePhoneStatus: CubitStates.initial,
        errorMessage: '',
        phoneError: '',
      ),
    );
  }
}
