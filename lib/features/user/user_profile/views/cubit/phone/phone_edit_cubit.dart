import 'dart:developer';
import 'package:tayseer/features/user/user_profile/data/repositories/user_settings_repository.dart';
import 'package:tayseer/my_import.dart';

part 'phone_edit_state.dart';

class PhoneEditCubit extends Cubit<PhoneEditState> {
  final UserSettingsRepository _repository;

  PhoneEditCubit(this._repository) : super(PhoneEditInitial());

  void initializePhone(String initialPhone, {CountryData? deviceCountry}) {
    log('PhoneEditCubit.initializePhone: initialPhone = "$initialPhone", deviceCountry = "${deviceCountry?.nameAr} (${deviceCountry?.code})"');
    if (initialPhone.isNotEmpty) {
      for (final country in kSupportedCountries) {
        if (initialPhone.startsWith(country.code)) {
          log('PhoneEditCubit.initializePhone: matched existing country prefix: ${country.nameAr} (${country.code})');
          emit(
            state.copyWith(
              selectedCountry: country,
              phoneNumber: initialPhone.substring(country.code.length),
            ),
          );
          validatePhoneNumber();
          return;
        }
      }
    }

    // لو ما لقيناش match أو الرقم فارغ → نستخدم دولة الجهاز أو السعودية
    final selected = deviceCountry ?? kDefaultCountry;
    log('PhoneEditCubit.initializePhone: no matching prefix or empty. Selecting deviceCountry/default: ${selected.nameAr} (${selected.code})');
    emit(state.copyWith(selectedCountry: selected));
    validatePhoneNumber();
  }

  void updateCountry(CountryData country) {
    emit(state.copyWith(selectedCountry: country));
    validatePhoneNumber();
  }

  void updatePhoneNumber(String phone) {
    // لو بدأ بصفر وفيه أرقام بعده → نشيل الصفر (المستخدم حاطه عادةً قبل الرقم)
    final cleaned = (phone.startsWith('0') && phone.length > 1)
        ? phone.substring(1)
        : phone;
    emit(state.copyWith(phoneNumber: cleaned, isDirty: true));
    validatePhoneNumber();
  }

  void validatePhoneNumber() {
    String error = '';
    final phone = state.phoneNumber.trim();

    if (phone.isEmpty) {
      error = 'field_required';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      error = 'invalid_phone';
    } else if (phone.length < 8) {
      error = 'invalid_phone';
    } else if (phone.length > 15) {
      error = 'invalid_phone';
    } else {
      if (state.selectedCountry.code == '+966' && !phone.startsWith('5')) {
        error = 'invalid_phone';
      } else if (state.selectedCountry.code == '+20' &&
          !phone.startsWith('1')) {
        error = 'invalid_phone';
      }
    }

    emit(state.copyWith(phoneError: error));
  }

  Future<void> updatePhone() async {
    if (state.phoneNumber.isEmpty || state.phoneError.isNotEmpty) return;

    emit(
      state.copyWith(
        updatePhoneStatus: CubitStates.loading,
        errorMessage: '',
        successMessage: '',
      ),
    );

    final cleanedPhone = state.phoneNumber.replaceAll(RegExp(r'\D'), '');
    log('طلب تحديث الهاتف: ${state.selectedCountry.code}$cleanedPhone');

    final result = await _repository.updatePhoneNumber(
      countryCode: state.selectedCountry.code,
      phoneNumber: cleanedPhone,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          updatePhoneStatus: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          updatePhoneStatus: CubitStates.success,
          fullPhoneNumber: '${state.selectedCountry.code}$cleanedPhone',
          successMessage: 'otp_sent_success',
          errorMessage: '',
        ),
      ),
    );
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
