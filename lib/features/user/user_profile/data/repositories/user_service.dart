// features/user/user_profile/data/repositories/user_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserService {
  static Future<String?> getCurrentUserId() async {
    try {
      // الطريقة 1: من SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // محاولة الحصول من token أو user_data
      final token = prefs.getString('token');
      final userData = prefs.getString('user_data');

      if (userData != null) {
        try {
          final Map<String, dynamic> user = jsonDecode(userData);
          return user['id']?.toString();
        } catch (e) {
          print('❌ Error parsing user data: $e');
        }
      }

      // الطريقة 2: إذا كان لديك Bloc/Cubit للمستخدم
      // يمكنك استخدام: context.read<UserCubit>().state.user?.id

      // الطريقة 3: من الـ token نفسه (إذا كان يحتوي على ID)
      if (token != null && token.contains('.')) {
        try {
          final parts = token.split('.');
          if (parts.length >= 2) {
            final payload = parts[1];
            final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
            return decoded['userId']?.toString() ?? decoded['id']?.toString();
          }
        } catch (e) {
          print('❌ Error extracting ID from token: $e');
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        return jsonDecode(userData);
      }

      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // دالة سريعة للمزامنة (لكنها async)
  static Future<String?> getUserIdSync() async {
    return await getCurrentUserId();
  }
}
