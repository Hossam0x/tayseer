import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/shared/network/local_network.dart';

/// Helper للقراءة والكتابة الـ sync للـ subscription type من الـ SharedPreferences.
///
/// بيتحفظ في كل مكان بيتغير فيه الـ subscription (purchase / restore / event bus)
/// ويتقرأ في أي widget/cubit قبل ما الـ API يرجع.
class SubscriptionCache {
  SubscriptionCache._();

  /// اقرأ الـ subscription type المحفوظ — 'free' | 'gold' | 'ultra'
  /// بيرجع 'free' لو مفيش حاجة محفوظة
  static String get subscriptionType =>
      CachNetwork.getStringData(key: kSubscriptionType).isEmpty
      ? 'free'
      : CachNetwork.getStringData(key: kSubscriptionType);

  static bool get isSubscribed {
    final t = subscriptionType;
    return t == 'gold' || t == 'ultra';
  }

  /// احفظ الـ subscription type — استدعيها عند كل تغيير
  static Future<void> save(String subscriptionType) async {
    await CachNetwork.setData(key: kSubscriptionType, value: subscriptionType);
  }

  /// امسح عند الـ logout
  static Future<void> clear() async {
    await CachNetwork.setData(key: kSubscriptionType, value: 'free');
  }
}
