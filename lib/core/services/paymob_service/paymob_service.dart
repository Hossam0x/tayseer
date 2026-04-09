import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymobService {
  static const MethodChannel _channel = MethodChannel('paymob_sdk_flutter');

  /// الـ Public Key من .env
  static String get _publicKey => dotenv.env['PAYMOB_PUBLIC_KEY'] ?? '';

  /// فتح Paymob SDK وبدء الدفع
  /// بيرجع: "Successfull" / "Rejected" / "Pending"
  static Future<String> pay({required String clientSecret}) async {
    try {
      debugPrint('🔄 [PaymobService] Opening SDK...');
      debugPrint(
        '🔑 [PaymobService] PublicKey exists: ${_publicKey.isNotEmpty}',
      );

      final dynamic result = await _channel.invokeMethod('payWithPaymob', {
        'publicKey': _publicKey,
        'clientSecret': clientSecret,
        'appName': 'تيسير',
        'saveCardDefault': false,
        'showSaveCard': true,
      });

      debugPrint('✅ [PaymobService] Result: $result');

      // iOS بيرجع Map
      if (result is Map) {
        return result['status']?.toString() ?? 'Unknown';
      }

      // Android بيرجع String
      return result.toString();
    } on PlatformException catch (e) {
      debugPrint('❌ [PaymobService] Error: ${e.message}');
      rethrow;
    }
  }
}
