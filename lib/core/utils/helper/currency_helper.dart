import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tayseer/core/constant/constans.dart';

class CurrencyHelper {
  CurrencyHelper._(); // ✅ منع إنشاء instance

  // ═══════════════════════════════════════════════════════════
  // ✅ خريطة البلد → رمز العملة المحلي
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _currencySymbols = {
    // ───── الخليج ─────
    'SA': 'ر.س', // السعودية
    'AE': 'د.إ', // الإمارات
    'KW': 'د.ك', // الكويت
    'QA': 'ر.ق', // قطر
    'BH': 'د.ب', // البحرين
    'OM': 'ر.ع', // عمان
    // ───── عربي ─────
    'EG': 'ج.م', // مصر
    'JO': 'د.أ', // الأردن
    'LB': 'ل.ل', // لبنان
    'IQ': 'د.ع', // العراق
    'SY': 'ل.س', // سوريا
    'SD': 'ج.س', // السودان
    'LY': 'د.ل', // ليبيا
    'TN': 'د.ت', // تونس
    'DZ': 'د.ج', // الجزائر
    'MA': 'د.م', // المغرب
    'YE': 'ر.ي', // اليمن
    'PS': '₪', // فلسطين
    // ───── عالمي ─────
    'US': '\$', // أمريكا
    'GB': '£', // بريطانيا
    'TR': '₺', // تركيا
    'DE': '€', // ألمانيا
    'FR': '€', // فرنسا
    'IT': '€', // إيطاليا
    'ES': '€', // إسبانيا
    'NL': '€', // هولندا
    'BE': '€', // بلجيكا
    'AT': '€', // النمسا
    'PT': '€', // البرتغال
    'GR': '€', // اليونان
    'IE': '€', // أيرلندا
    'IN': '₹', // الهند
    'PK': 'Rs', // باكستان
    'MY': 'RM', // ماليزيا
    'ID': 'Rp', // إندونيسيا
    'JP': '¥', // اليابان
    'CN': '¥', // الصين
    'KR': '₩', // كوريا الجنوبية
    'RU': '₽', // روسيا
    'BR': 'R\$', // البرازيل
    'ZA': 'R', // جنوب أفريقيا
    'NG': '₦', // نيجيريا
    'CA': 'CA\$', // كندا
    'AU': 'A\$', // أستراليا
  };

  // ═══════════════════════════════════════════════════════════
  // ✅ خريطة البلد → كود العملة الدولي (ISO 4217)
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> _currencyCodes = {
    // ───── الخليج ─────
    'SA': 'SAR',
    'AE': 'AED',
    'KW': 'KWD',
    'QA': 'QAR',
    'BH': 'BHD',
    'OM': 'OMR',

    // ───── عربي ─────
    'EG': 'EGP',
    'JO': 'JOD',
    'LB': 'LBP',
    'IQ': 'IQD',
    'SY': 'SYP',
    'SD': 'SDG',
    'LY': 'LYD',
    'TN': 'TND',
    'DZ': 'DZD',
    'MA': 'MAD',
    'YE': 'YER',
    'PS': 'ILS',

    // ───── عالمي ─────
    'US': 'USD',
    'GB': 'GBP',
    'TR': 'TRY',
    'DE': 'EUR',
    'FR': 'EUR',
    'IT': 'EUR',
    'ES': 'EUR',
    'NL': 'EUR',
    'BE': 'EUR',
    'AT': 'EUR',
    'PT': 'EUR',
    'GR': 'EUR',
    'IE': 'EUR',
    'IN': 'INR',
    'PK': 'PKR',
    'MY': 'MYR',
    'ID': 'IDR',
    'JP': 'JPY',
    'CN': 'CNY',
    'KR': 'KRW',
    'RU': 'RUB',
    'BR': 'BRL',
    'ZA': 'ZAR',
    'NG': 'NGN',
    'CA': 'CAD',
    'AU': 'AUD',
  };

  /// ★ الحصول على كود العملة بناءً على مفتاح الدولة
  static String getCurrencyCodeByCountryKey(String countryKey) {
    switch (countryKey) {
      case 'country_saudi':
        return 'SAR';
      case 'country_egypt':
        return 'EGP';
      case 'country_emirati':
        return 'AED';
      case 'country_kuwait':
        return 'KWD';
      case 'country_qatar':
        return 'QAR';
      case 'country_bahrain':
        return 'BHD';
      case 'country_jordan':
        return 'JOD';
      case 'country_palestine':
        return 'ILS';
      case 'country_morocco':
        return 'MAD';
      case 'country_tunisia':
        return 'TND';
      default:
        return 'SAR';
    }
  }

  /// ★ جلب رمز العملة بناءً على مفتاح الدولة الخاص بالتطبيق (عربي)
  static String getCurrencySymbolByCountryKey(String countryKey) {
    switch (countryKey) {
      case 'country_saudi':
        return 'ر.س';
      case 'country_egypt':
        return 'ج.م';
      case 'country_emirati':
        return 'د.إ';
      case 'country_kuwait':
        return 'د.ك';
      case 'country_qatar':
        return 'ر.ق';
      case 'country_bahrain':
        return 'د.ب';
      case 'country_jordan':
        return 'د.أ';
      case 'country_palestine':
        return '₪';
      case 'country_morocco':
        return 'د.م';
      case 'country_tunisia':
        return 'د.ت';
      default:
        return getCurrencySymbol();
    }
  }

  /// ★ جلب رمز العملة بناءً على مفتاح الدولة (إنجليزي)
  static String getCurrencySymbolEnByCountryKey(String countryKey) {
    switch (countryKey) {
      case 'country_saudi':
        return 'SAR';
      case 'country_egypt':
        return 'EGP';
      case 'country_emirati':
        return 'AED';
      case 'country_kuwait':
        return 'KWD';
      case 'country_qatar':
        return 'QAR';
      case 'country_bahrain':
        return 'BHD';
      case 'country_jordan':
        return 'JOD';
      case 'country_palestine':
        return 'ILS';
      case 'country_morocco':
        return 'MAD';
      case 'country_tunisia':
        return 'TND';
      default:
        return getCurrencyCode();
    }
  }

  /// ★ جلب رمز العملة حسب اللغة الحالية للتطبيق
  static String getCurrencySymbolLocalized(String countryKey) {
    return isArabic
        ? getCurrencySymbolByCountryKey(countryKey)
        : getCurrencySymbolEnByCountryKey(countryKey);
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب كود البلد من الجهاز
  // ═══════════════════════════════════════════════════════════
  static String getDeviceCountryCode() {
    try {
      final String locale = Platform.localeName; // مثلاً: ar_SA, en_US
      final parts = locale.split('_');
      if (parts.length >= 2) {
        return parts.last.toUpperCase(); // SA, US, EG...
      }
    } catch (_) {}
    return 'SA'; // القيمة الافتراضية
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب كود البلد من الـ Context (أدق)
  // ═══════════════════════════════════════════════════════════
  static String getCountryFromContext(BuildContext context) {
    try {
      final locale = Localizations.localeOf(context);
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        return locale.countryCode!.toUpperCase();
      }
    } catch (_) {}
    return getDeviceCountryCode();
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب رمز العملة (ر.س، ج.م، $...)
  // ═══════════════════════════════════════════════════════════
  static String getCurrencySymbol([String? countryCode]) {
    final code = countryCode ?? getDeviceCountryCode();
    return _currencySymbols[code.toUpperCase()] ?? '\$';
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب رمز العملة من الـ Context
  // ═══════════════════════════════════════════════════════════
  static String getCurrencySymbolFromContext(BuildContext context) {
    final code = getCountryFromContext(context);
    return getCurrencySymbol(code);
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب كود العملة الدولي (SAR, EGP, USD...)
  // ═══════════════════════════════════════════════════════════
  static String getCurrencyCode([String? countryCode]) {
    final code = countryCode ?? getDeviceCountryCode();
    return _currencyCodes[code.toUpperCase()] ?? 'USD';
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ جلب كود العملة الدولي من الـ Context
  // ═══════════════════════════════════════════════════════════
  static String getCurrencyCodeFromContext(BuildContext context) {
    final code = getCountryFromContext(context);
    return getCurrencyCode(code);
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ تنسيق السعر مع العملة
  // ═══════════════════════════════════════════════════════════
  static String formatPrice(num price, [String? countryCode]) {
    final symbol = getCurrencySymbol(countryCode);
    return '$price $symbol';
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ تنسيق السعر مع العملة من الـ Context
  // ═══════════════════════════════════════════════════════════
  static String formatPriceFromContext(BuildContext context, num price) {
    final symbol = getCurrencySymbolFromContext(context);
    return '$price $symbol';
  }
}
