/// Status values returned by the API
enum AppVersionStatus { forceUpdate, optionalUpdate, upToDate }

class AppVersionModel {
  final AppVersionStatus status;
  final bool forceUpdate;
  final bool updateAvailable;
  final String iosLink;
  final String androidLink;

  const AppVersionModel({
    required this.status,
    required this.forceUpdate,
    required this.updateAvailable,
    required this.iosLink,
    required this.androidLink,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final statusStr = data['status']?.toString() ?? '';
    final AppVersionStatus status;
    switch (statusStr) {
      case 'force_update':
        status = AppVersionStatus.forceUpdate;
        break;
      case 'optional_update':
        status = AppVersionStatus.optionalUpdate;
        break;
      default:
        status = AppVersionStatus.upToDate;
    }

    return AppVersionModel(
      status: status,
      forceUpdate: data['forceUpdate'] == true,
      updateAvailable: data['updateAvailable'] == true,
      iosLink: data['iosLink']?.toString() ?? '',
      androidLink: data['androidLink']?.toString() ?? '',
    );
  }
}
