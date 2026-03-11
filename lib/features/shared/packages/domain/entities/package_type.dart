enum PackageType { basic, pro, elite }

extension PackageTypeExtension on PackageType {
  String get id {
    switch (this) {
      case PackageType.basic:
        return 'basic';
      case PackageType.pro:
        return 'pro';
      case PackageType.elite:
        return 'elite';
    }
  }

  String get apiType {
    switch (this) {
      case PackageType.basic:
        return 'Free';
      case PackageType.pro:
        return 'pro';
      case PackageType.elite:
        return 'elite';
    }
  }
}
