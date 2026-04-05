enum VerificationType {
  full,
  basic,
  none;

  static VerificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'full':
        return VerificationType.full;
      case 'basic':
        return VerificationType.basic;
      default:
        return VerificationType.none;
    }
  }
}
