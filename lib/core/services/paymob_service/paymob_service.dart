import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// نتيجة دفع Paymob
class PaymobResult {
  /// "Successfull" / "Rejected" / "Pending"
  final String status;

  /// الـ payResponse كاملاً من الـ SDK (Android فقط — iOS بيرجع status فقط)
  /// ممكن يحتوي على: token, masked_pan, card_subtype, order_id, ...
  final Map<String, dynamic> data;

  const PaymobResult({required this.status, this.data = const {}});

  bool get isSuccess => status == 'Successfull';
  bool get isRejected => status == 'Rejected';
  bool get isPending => status == 'Pending';

  /// الـ card token لو المستخدم حفظ الكارت
  String? get cardToken => data['token']?.toString();

  /// الـ masked pan لو موجود
  String? get maskedPan => data['masked_pan']?.toString();
}

class PaymobService {
  static const MethodChannel _channel = MethodChannel('paymob_sdk_flutter');

  /// فتح Paymob SDK وبدء الدفع
  /// بيرجع [PaymobResult] فيه الـ status + الـ payResponse data
  static Future<PaymobResult> pay({
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

      debugPrint('✅ [PaymobService] Raw result: $result');

      // Android + iOS بيرجعوا Map فيها status + payResponse data
      if (result is Map) {
        final status = result['status']?.toString() ?? 'Unknown';
        final data = Map<String, dynamic>.from(result);
        data.remove('status'); // نشيل الـ status من الـ data
        debugPrint('✅ [PaymobService] Status: $status');
        debugPrint('✅ [PaymobService] Data keys: ${data.keys.toList()}');
        if (data['token'] != null) {
          debugPrint('💳 [PaymobService] Card token present: ${data['token']}');
        }
        return PaymobResult(status: status, data: data);
      }

      // fallback لو رجع String (iOS قديم)
      return PaymobResult(status: result.toString());
    } on PlatformException catch (e) {
      debugPrint('❌ [PaymobService] Error: ${e.message}');
      rethrow;
    }
  }
}
