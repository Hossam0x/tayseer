import 'package:google_sign_in/google_sign_in.dart';

String getGoogleSignInErrorMessage(String code) {
  switch (code) {
    case GoogleSignIn.kSignInCanceledError:
      return 'تم إلغاء تسجيل الدخول';
    case GoogleSignIn.kSignInFailedError:
      return 'فشل تسجيل الدخول';
    case GoogleSignIn.kNetworkError:
      return 'خطأ في الاتصال بالإنترنت';
    default:
      return 'حدث خطأ: $code';
  }
}
