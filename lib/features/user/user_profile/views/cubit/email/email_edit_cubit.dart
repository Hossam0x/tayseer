import 'dart:developer';
import 'package:tayseer/features/user/user_profile/data/repositories/user_settings_repository.dart';
import 'package:tayseer/my_import.dart';

part 'email_edit_state.dart';

class EmailEditCubit extends Cubit<EmailEditState> {
  final UserSettingsRepository _repository;

  EmailEditCubit(this._repository) : super(EmailEditInitial());

  /// يُستدعى عند تغيير المستخدم للنص — يضبط isDirty ويعرض الـ error
  void updateEmail(String email, {bool markDirty = false}) {
    emit(
      state.copyWith(
        email: email.trim(),
        emailError: '',
        isDirty: markDirty ? true : state.isDirty,
      ),
    );
    _validate();
  }

  void _validate() {
    String error = '';
    final email = state.email;

    if (email.isEmpty) {
      error = 'email_required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      error = 'invalid_email';
    }

    emit(state.copyWith(emailError: error));
  }

  Future<void> updateEmailRequest() async {
    if (state.email.isEmpty || state.emailError.isNotEmpty) return;

    emit(
      state.copyWith(
        status: CubitStates.loading,
        errorMessage: '',
        successMessage: '',
      ),
    );

    log('طلب تغيير الإيميل → ${state.email}');

    final result = await _repository.updateEmail(email: state.email);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: CubitStates.success,
          fullEmail: state.email,
          successMessage: 'otp_sent_success',
          errorMessage: '',
        ),
      ),
    );
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: '', successMessage: ''));
  }

  void reset() {
    emit(
      EmailEditInitial().copyWith(
        status: CubitStates.initial,
        errorMessage: '',
        emailError: '',
      ),
    );
  }
}
