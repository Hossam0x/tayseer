// features/user/user_profile/views/cubit/email/email_edit_cubit.dart
import 'dart:developer';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/my_import.dart';
part 'email_edit_state.dart';

class EmailEditCubit extends Cubit<EmailEditState> {
  final ApiService _apiService;
  final SnackBarService _snackBarService = SnackBarService();

  EmailEditCubit() : _apiService = ApiService(Dio()), super(EmailEditInitial());

  void updateEmail(String email) {
    emit(state.copyWith(email: email.trim()));
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

  Future<void> updateEmailRequest(BuildContext context) async {
    if (state.email.isEmpty || state.emailError.isNotEmpty) {
      if (state.emailError.isNotEmpty) {
        _snackBarService.showSnackBar(
          context: context,
          text: state.emailError,
          isError: true,
        );
      }
      return;
    }

    emit(state.copyWith(status: CubitStates.loading));

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
            errorMessage: '',
          ),
        );
        _snackBarService.showSnackBar(
          context: context,
          text: 'تم إرسال رمز التحقق بنجاح',
          isSuccess: true,
        );
      } else {
        final msg = response['message'] ?? 'فشل تحديث البريد';
        emit(state.copyWith(status: CubitStates.failure, errorMessage: msg));
        _snackBarService.showSnackBar(
          context: context,
          text: msg,
          isError: true,
        );
      }
    } on DioException catch (e) {
      final failure = ServerFailure.fromDioError(e);
      emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: failure.message,
        ),
      );
      _snackBarService.showSnackBar(
        context: context,
        text: failure.message,
        isError: true,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CubitStates.failure,
          errorMessage: 'حدث خطأ غير متوقع',
        ),
      );
      _snackBarService.showSnackBar(
        context: context,
        text: 'حدث خطأ غير متوقع',
        isError: true,
      );
    }
  }

  void reset() {
    emit(
      state.copyWith(
        status: CubitStates.initial,
        errorMessage: '',
        emailError: '',
      ),
    );
  }
}
