// features/user/user_profile/views/cubit/email/email_edit_cubit.dart
import 'dart:developer';
import 'package:tayseer/my_import.dart';
part 'email_edit_state.dart';

class EmailEditCubit extends Cubit<EmailEditState> {
  final ApiService _apiService;

  EmailEditCubit() : _apiService = ApiService(Dio()), super(EmailEditInitial());

  void updateEmail(String email) {
    emit(state.copyWith(email: email.trim(), emailError: ''));
    _validate();
  }

  void _validate() {
    String error = '';
    final email = state.email;

    if (email.isEmpty) {
      error = 'يرجى إدخال البريد الإلكتروني';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      error = 'البريد الإلكتروني غير صالح';
    }

    emit(state.copyWith(emailError: error));
  }

  Future<void> updateEmailRequest() async {
    if (state.email.isEmpty || state.emailError.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        status: CubitStates.loading,
        errorMessage: '',
        successMessage: '',
      ),
    );

    try {
      log('طلب تغيير الإيميل → ${state.email}');

      final response = await _apiService.post(
        endPoint: '/user/update-email',
        data: {'email': state.email},
      );

      log('الرد: $response');

      if (response['success'] == true) {
        emit(
          state.copyWith(
            status: CubitStates.success,
            fullEmail: state.email,
            successMessage: 'تم إرسال رمز التحقق بنجاح',
            errorMessage: '',
          ),
        );
      } else {
        final msg = response['message'] ?? 'فشل تحديث البريد';
        emit(state.copyWith(status: CubitStates.failure, errorMessage: msg));
      }
    } on DioException catch (e) {
      final failure = ServerFailure.fromDioError(e);
      emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: 'حدث خطأ غير متوقع',
        ),
      );
    }
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
