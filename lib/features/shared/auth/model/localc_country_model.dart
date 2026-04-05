// 1. إنشاء Model محلي بسيط للدول
class LocalCountryModel {
  final String translationKey;
  final String flagEmoji;
  final bool isMostRequested;

  LocalCountryModel({
    required this.translationKey,
    required this.flagEmoji,
    this.isMostRequested = false,
  });
}
