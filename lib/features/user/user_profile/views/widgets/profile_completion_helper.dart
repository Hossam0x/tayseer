
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/my_import.dart';

class ProfileCompletionHelper {
  // ⭐ إجمالي عدد الأسئلة
  static const int totalQuestions = 24;

  // ⭐⭐⭐ حساب نسبة الإكمال من MarriageUserProfileModel
  static double calculateCompletionPercentage(
    MarriageUserProfileModel? profile,
  ) {
    if (profile == null) return 0.0;

    // الحصول على آخر رقم سؤال من الـ API
    final lastQuestionNumber = profile.lastQuestionNumber ?? 0;

    if (lastQuestionNumber == 0) return 0.0;

    // حساب النسبة المئوية
    final percentage = (lastQuestionNumber / totalQuestions);

    // التأكد من أن النسبة بين 0 و 1
    return percentage.clamp(0.0, 1.0);
  }

  // ⭐⭐⭐ الحصول على رقم آخر سؤال
  static int getLastQuestionNumber(MarriageUserProfileModel? profile) {
    return profile?.lastQuestionNumber ?? 0;
  }

  // ⭐⭐⭐ الحصول على عدد الأسئلة المتبقية
  static int getRemainingQuestions(MarriageUserProfileModel? profile) {
    final lastQuestion = getLastQuestionNumber(profile);
    return totalQuestions - lastQuestion;
  }

  // ⭐⭐⭐ التحقق من اكتمال الملف الشخصي
  static bool isProfileComplete(MarriageUserProfileModel? profile) {
    return getLastQuestionNumber(profile) >= totalQuestions;
  }

  // ⭐⭐⭐ الحصول على نص نسبة الإكمال
  static String getCompletionText(MarriageUserProfileModel? profile) {
    final percentage = calculateCompletionPercentage(profile);
    final percentageInt = (percentage * 100).toInt();
    return '$percentageInt%';
  }

  // ⭐⭐⭐ الحصول على رسالة التشجيع بناءً على النسبة
  static String getMotivationMessage(MarriageUserProfileModel? profile) {
    final percentage = calculateCompletionPercentage(profile);

    if (percentage >= 1.0) {
      return 'تهانينا! أكملت ملفك الشخصي بنجاح';
    } else if (percentage >= 0.75) {
      return 'أوشكت على الانتهاء! بقي القليل';
    } else if (percentage >= 0.50) {
      return 'أنت في منتصف الطريق، استمر!';
    } else if (percentage >= 0.25) {
      return 'بداية جيدة! واصل إكمال بياناتك';
    } else if (percentage > 0) {
      return 'ابدأ الآن في إكمال ملفك الشخصي';
    } else {
      return 'ادخل البيانات الشخصية كاملة حتى تتمكن من إيجاد شريكك المناسب';
    }
  }

  // ⭐⭐⭐ الحصول على اللون بناءً على النسبة
  static Color getProgressColor(double percentage) {
    if (percentage >= 1.0) {
      return Colors.green;
    } else if (percentage >= 0.75) {
      return Colors.lightGreen;
    } else if (percentage >= 0.50) {
      return Colors.orange;
    } else {
      return const Color(0xFFE91E63); // اللون الوردي الأساسي
    }
  }
}










