import 'dart:developer';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:tayseer/core/services/paymob_config_service.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/shared/force_update/data/models/app_version_model.dart';

class ForceUpdateRepo {
  final ApiService _apiService;
  final PaymobConfigService _paymobConfig;

  ForceUpdateRepo(this._apiService, this._paymobConfig);

  Future<AppVersionModel?> fetchVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final endpoint = Platform.isAndroid
          ? ApiEndPoint.checkForUpdateAndroid
          : ApiEndPoint.checkForUpdateIos;

      final response = await _apiService.post(
        endPoint: endpoint,
        data: {'currentVersion': currentVersion},
      );
      return AppVersionModel.fromJson(response);
    } catch (e) {
      log('⚠️ ForceUpdateRepo: failed to fetch version info — $e');
      return null;
    }
  }

  Future<bool> isUpdateRequired() async {
    try {
      final versionInfo = await fetchVersionInfo();
      if (versionInfo == null) return false;

      return versionInfo.status == AppVersionStatus.forceUpdate;
    } catch (e) {
      log('⚠️ ForceUpdateRepo: isUpdateRequired error — $e');
      return false;
    }
  }

  Future<String> getStoreUrl() async {
    try {
      final versionInfo = await fetchVersionInfo();
      if (versionInfo == null) return _defaultStoreUrl();

      final url = Platform.isIOS
          ? versionInfo.iosLink
          : versionInfo.androidLink;
      return url.isNotEmpty ? url : _defaultStoreUrl();
    } catch (e) {
      return _defaultStoreUrl();
    }
  }

  String _defaultStoreUrl() {
    return Platform.isIOS
        ? _paymobConfig.iosLink
        : _paymobConfig.androidLink;
  }
}
