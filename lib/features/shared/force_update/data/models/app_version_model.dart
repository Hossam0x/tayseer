class AppVersionModel {
  final String minVersion;
  final String latestVersion;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final bool forceUpdate;

  const AppVersionModel({
    required this.minVersion,
    required this.latestVersion,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.forceUpdate,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AppVersionModel(
      minVersion: data['min_version']?.toString() ?? '0.0.0',
      latestVersion: data['latest_version']?.toString() ?? '0.0.0',
      androidStoreUrl: data['android_store_url']?.toString() ?? '',
      iosStoreUrl: data['ios_store_url']?.toString() ?? '',
      forceUpdate: data['force_update'] == true,
    );
  }
}
