class PackageFeatureModel {
  final String title;
  final String iconPath;
  final String? subtitle;

  const PackageFeatureModel({
    required this.title,
    required this.iconPath,
    this.subtitle,
  });
}
