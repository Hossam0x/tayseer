import 'dart:developer';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/shared/force_update/data/models/app_version_model.dart';

class ForceUpdateRepo {
  final ApiService _apiService;

  ForceUpdateRepo(this._apiService);

  /// يجيب الـ version الحالية من الجهاز ويبعتها للـ API
  /// يرجع [AppVersionModel] لو الـ API نجح، أو null لو فشل
  Future<AppVersionModel?> fetchVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _apiService.post(
        endPoint: ApiEndPoint.checkForUpdate,
        data: {'currentVersion': currentVersion},
      );
      return AppVersionModel.fromJson(response);
    } catch (e) {
      log('⚠️ ForceUpdateRepo: failed to fetch version info — $e');
      return null;
    }
  }

  /// يرجع true لو الـ API قال status = force_update
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

  /// يرجع رابط الـ store المناسب للـ platform
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
    if (Platform.isIOS) {
      return 'https://apps.apple.com/eg/app/tayseer-community/id6756886227';
    }
    return 'https://play.google.com/store/apps/details?id=com.tayseer.app';
  }
}
