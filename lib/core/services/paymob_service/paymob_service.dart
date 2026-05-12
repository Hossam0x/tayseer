import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PaymobService {
  static const MethodChannel _channel = MethodChannel('paymob_sdk_flutter');

  /// فتح Paymob SDK وبدء الدفع
  /// بيرجع: "Successfull" / "Rejected" / "Pending"
  static Future<String> pay({
    required String clientSecret,
    required String publicKey,
  }) async {
    try {
      debugPrint('🔄 [PaymobService] Opening SDK...');
      debugPrint(
        '🔑 [PaymobService] PublicKey exists: ${publicKey.isNotEmpty}',
      );

      final dynamic result = await _channel.invokeMethod('payWithPaymob', {
        'publicKey': publicKey,
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
