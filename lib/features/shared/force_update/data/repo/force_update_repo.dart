import 'dart:developer';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/shared/force_update/data/models/app_version_model.dart';

class ForceUpdateRepo {
  final ApiService _apiService;

  ForceUpdateRepo(this._apiService);

  /// يرجع [AppVersionModel] لو الـ API نجح، أو null لو فشل
  Future<AppVersionModel?> fetchVersionInfo() async {
    try {
      final response = await _apiService.get(endPoint: ApiEndPoint.appVersion);
      return AppVersionModel.fromJson(response);
    } catch (e) {
      log('⚠️ ForceUpdateRepo: failed to fetch version info — $e');
      return null;
    }
  }

  /// يقارن الـ version الحالية بالـ min_version من الـ API
  /// يرجع true لو المستخدم محتاج يحدّث
  Future<bool> isUpdateRequired() async {
    try {
      final versionInfo = await fetchVersionInfo();
      if (versionInfo == null) return false;

      // لو الـ API بيقول force_update مباشرة
      if (versionInfo.forceUpdate) return true;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return _isVersionLower(currentVersion, versionInfo.minVersion);
    } catch (e) {
      log('⚠️ ForceUpdateRepo: isUpdateRequired error — $e');
      return false;
    }
  }

  /// يرجع رابط الـ store المناسب للـ platform
  Future<String> getStoreUrl() async {
    try {
      final versionInfo = await fetchVersionInfo();
      if (versionInfo == null) return _defaultStoreUrl();

      return Platform.isIOS
          ? versionInfo.iosStoreUrl
          : versionInfo.androidStoreUrl;
    } catch (e) {
      return _defaultStoreUrl();
    }
  }

  String _defaultStoreUrl() {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/eg/app/tayseer-community/id6756886227';
    }
    return 'https://play.google.com/store/apps/details?id=com.tayseer.app';
  }

  /// يقارن نسختين بصيغة "1.2.3"
  /// يرجع true لو [current] أقل من [minimum]
  bool _isVersionLower(String current, String minimum) {
    final currentParts = _parseParts(current);
    final minimumParts = _parseParts(minimum);

    for (int i = 0; i < 3; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final m = i < minimumParts.length ? minimumParts[i] : 0;
      if (c < m) return true;
      if (c > m) return false;
    }
    return false; // متساويتين
  }

  List<int> _parseParts(String version) {
    return version
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }
}
