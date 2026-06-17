import 'dart:developer';

import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';

class PaymobConfigService {
  final ApiService _apiService;

  static const _kPaymobActive = 'paymob_active';
  static const _kAndroidLink = 'android_store_link';
  static const _kIosLink = 'ios_store_link';

  static const defaultAndroidLink =
      'https://play.google.com/store/apps/details?id=com.athr.tayser';
  static const defaultIosLink =
      'https://apps.apple.com/eg/app/tayseer-community/id6756886227';

  PaymobConfigService(this._apiService);

  bool get isPaymobActive =>
      CachNetwork.getBoolData(key: _kPaymobActive) ?? false;

  String get androidLink {
    final cached = CachNetwork.getStringData(key: _kAndroidLink);
    return cached.isNotEmpty ? cached : defaultAndroidLink;
  }

  String get iosLink {
    final cached = CachNetwork.getStringData(key: _kIosLink);
    return cached.isNotEmpty ? cached : defaultIosLink;
  }

  Future<void> fetchAndUpdateStatus() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.paymobStatus,
      );
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final paymobActive = data['paymobActive'] as bool? ?? false;
        final newAndroidLink = (data['androidLink'] as String?) ?? '';
        final newIosLink = (data['iosLink'] as String?) ?? '';

        final prevActive =
            CachNetwork.getBoolData(key: _kPaymobActive) ?? false;
        final prevAndroid = CachNetwork.getStringData(key: _kAndroidLink);
        final prevIos = CachNetwork.getStringData(key: _kIosLink);

        if (prevActive != paymobActive) {
          await CachNetwork.setBool(key: _kPaymobActive, value: paymobActive);
        }
        if (newAndroidLink.isNotEmpty && prevAndroid != newAndroidLink) {
          await CachNetwork.setData(key: _kAndroidLink, value: newAndroidLink);
        }
        if (newIosLink.isNotEmpty && prevIos != newIosLink) {
          await CachNetwork.setData(key: _kIosLink, value: newIosLink);
        }
      }
    } catch (e) {
      log('PaymobConfigService: failed to fetch status — $e');
    }
  }
}
