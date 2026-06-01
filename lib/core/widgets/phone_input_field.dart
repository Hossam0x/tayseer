import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:tayseer/my_import.dart';

/// بيانات الدولة المختارة
class CountryData {
  final String nameAr;
  final String nameEn;
  final String code;
  final String flag;

  const CountryData({
    required this.nameAr,
    required this.nameEn,
    required this.code,
    required this.flag,
  });

  /// الاسم المعروض حسب لغة التطبيق
  String displayName(bool arabic) => arabic ? nameAr : nameEn;

  /// يطابق البحث بالعربي أو الإنجليزي بغض النظر عن لغة التطبيق
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return nameAr.toLowerCase().contains(q) ||
        nameEn.toLowerCase().contains(q) ||
        code.contains(q);
  }

  @override
  bool operator ==(Object other) => other is CountryData && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// قائمة الدول المدعومة
const List<CountryData> kSupportedCountries = [
  CountryData(
    nameAr: "السعودية",
    nameEn: "Saudi Arabia",
    code: "+966",
    flag: "🇸🇦",
  ),
  CountryData(nameAr: "مصر", nameEn: "Egypt", code: "+20", flag: "🇪🇬"),
  CountryData(nameAr: "الإمارات", nameEn: "UAE", code: "+971", flag: "🇦🇪"),
  CountryData(nameAr: "الكويت", nameEn: "Kuwait", code: "+965", flag: "🇰🇼"),
  CountryData(nameAr: "قطر", nameEn: "Qatar", code: "+974", flag: "🇶🇦"),
  CountryData(nameAr: "عُمان", nameEn: "Oman", code: "+968", flag: "🇴🇲"),
  CountryData(nameAr: "البحرين", nameEn: "Bahrain", code: "+973", flag: "🇧🇭"),
  CountryData(nameAr: "الأردن", nameEn: "Jordan", code: "+962", flag: "🇯🇴"),
  CountryData(nameAr: "لبنان", nameEn: "Lebanon", code: "+961", flag: "🇱🇧"),
  CountryData(nameAr: "العراق", nameEn: "Iraq", code: "+964", flag: "🇮🇶"),
  CountryData(nameAr: "المغرب", nameEn: "Morocco", code: "+212", flag: "🇲🇦"),
  CountryData(nameAr: "الجزائر", nameEn: "Algeria", code: "+213", flag: "🇩🇿"),
  CountryData(nameAr: "تونس", nameEn: "Tunisia", code: "+216", flag: "🇹🇳"),
];

/// الدولة الافتراضية (مصر)
const CountryData kDefaultCountry = CountryData(
  nameAr: "مصر",
  nameEn: "Egypt",
  code: "+20",
  flag: "🇪🇬",
);

/// يحدد الدولة الافتراضية بناءً على locale الجهاز.
/// آمنة للاستدعاء من initState وcreate callbacks — لا تحتاج context.
/// لو الدولة مش موجودة في القائمة يرجع السعودية.
CountryData resolveDefaultCountry([BuildContext? context]) {
  dev.log(
    '=== [DEBUG resolveDefaultCountry] Starting country code detection ===',
  );
  String countryCode = '';

  // 1. محاولة جلب كود الدولة من الـ context لو متوفر
  if (context != null) {
    try {
      final locale = Localizations.localeOf(context);
      dev.log(
        '[DEBUG resolveDefaultCountry] 1. context locale: $locale, countryCode: ${locale.countryCode}',
      );
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        countryCode = locale.countryCode!.toUpperCase();
        dev.log(
          '[DEBUG resolveDefaultCountry] 1. Set countryCode from context: $countryCode',
        );
      }
    } catch (e) {
      dev.log('[DEBUG resolveDefaultCountry] 1. Context check failed: $e');
    }
  }

  // 2. محاولة جلب كود الدولة من قائمة اللغات المفضلة للجهاز (locales list)
  if (countryCode.isEmpty) {
    try {
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      dev.log(
        '[DEBUG resolveDefaultCountry] 2. platformDispatcher.locales: $locales',
      );
      for (final locale in locales) {
        if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
          countryCode = locale.countryCode!.toUpperCase();
          dev.log(
            '[DEBUG resolveDefaultCountry] 2. Found countryCode in locales list: $countryCode',
          );
          break;
        }
      }
    } catch (e) {
      dev.log('[DEBUG resolveDefaultCountry] 2. Locales list check failed: $e');
    }
  }

  // 3. محاولة جلب كود الدولة وتحليله من Platform.localeName (أكثر دقة في الأندرويد مثل ar-EG أو en-SA)
  if (countryCode.isEmpty) {
    try {
      final String localeName = Platform.localeName;
      dev.log(
        '[DEBUG resolveDefaultCountry] 3. Platform.localeName: $localeName',
      );
      final parts = localeName.split(RegExp(r'[-_]'));
      dev.log('[DEBUG resolveDefaultCountry] 3. Split parts: $parts');
      if (parts.length >= 2) {
        // نتخطى الجزء الأول لأنه عادةً كود اللغة مثل 'ar' أو 'en' ونبحث في الأجزاء الأخرى عن كود الدولة المكون من حرفين
        for (int i = 1; i < parts.length; i++) {
          final cleaned = parts[i].trim().toUpperCase();
          if (cleaned.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(cleaned)) {
            countryCode = cleaned;
            dev.log(
              '[DEBUG resolveDefaultCountry] 3. Parsed countryCode from localeName: $countryCode',
            );
            break;
          }
        }
      }
    } catch (e) {
      dev.log(
        '[DEBUG resolveDefaultCountry] 3. Platform.localeName check failed: $e',
      );
    }
  }

  // 4. ملاذ أخير: كود دولة الـ locale الرئيسي من platformDispatcher
  if (countryCode.isEmpty) {
    try {
      final primaryLocale = WidgetsBinding.instance.platformDispatcher.locale;
      dev.log(
        '[DEBUG resolveDefaultCountry] 4. platformDispatcher.locale: $primaryLocale',
      );
      countryCode = primaryLocale.countryCode?.toUpperCase() ?? '';
      dev.log(
        '[DEBUG resolveDefaultCountry] 4. Fallback primary countryCode: $countryCode',
      );
    } catch (e) {
      dev.log(
        '[DEBUG resolveDefaultCountry] 4. Primary locale check failed: $e',
      );
    }
  }

  dev.log(
    '[DEBUG resolveDefaultCountry] Final detected countryCode = "$countryCode"',
  );

  const localeToDialCode = <String, String>{
    'SA': '+966',
    'EG': '+20',
    'AE': '+971',
    'KW': '+965',
    'QA': '+974',
    'OM': '+968',
    'BH': '+973',
    'JO': '+962',
    'LB': '+961',
    'IQ': '+964',
    'MA': '+212',
    'DZ': '+213',
    'TN': '+216',
  };

  final dialCode = localeToDialCode[countryCode];
  dev.log('[DEBUG resolveDefaultCountry] Mapped dialCode = "$dialCode"');

  if (dialCode == null) {
    dev.log(
      '[DEBUG resolveDefaultCountry] dialCode is null, returning kDefaultCountry: ${kDefaultCountry.nameAr}',
    );
    return kDefaultCountry;
  }

  final result = kSupportedCountries.firstWhere(
    (c) => c.code == dialCode,
    orElse: () => kDefaultCountry,
  );

  dev.log(
    '[DEBUG resolveDefaultCountry] Returning final resolved country: ${result.nameAr} (${result.code})',
  );
  return result;
}

/// Shared phone input widget — يُستخدم في جميع شاشات إدخال رقم الهاتف.
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final CountryData selectedCountry;
  final VoidCallback onCountryTap;
  final ValueChanged<String> onPhoneChanged;
  final String phoneError;
  final FocusNode? focusNode;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryTap,
    required this.onPhoneChanged,
    this.phoneError = '',
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = phoneError.isNotEmpty;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            textStyle: const TextStyle(decoration: TextDecoration.none),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasError ? Colors.red : AppColors.primary100,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    _CountrySelector(
                      country: selectedCountry,
                      hasError: hasError,
                      onTap: onCountryTap,
                    ),
                    Expanded(
                      child: _PhoneTextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onPhoneChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) ...[
            Gap(8.h),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Text(
                phoneError,
                style: Styles.textStyle12.copyWith(
                  color: Colors.red,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  final CountryData country;
  final bool hasError;
  final VoidCallback onTap;

  const _CountrySelector({
    required this.country,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.only(
          start: 12.w,
          top: 14.h,
          bottom: 14.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              color: hasError ? Colors.red : Colors.grey,
              size: 18.w,
            ),
            Gap(4.w),
            Text(country.flag, style: TextStyle(fontSize: 18.sp)),
            Gap(4.w),
            Text(
              country.code,
              style: Styles.textStyle14.copyWith(
                color: hasError ? Colors.red : AppColors.primary600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const _PhoneTextField({
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      style: Styles.textStyle14.copyWith(
        color: AppColors.secondary800,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: context.tr('phone_hint'),
        hintStyle: Styles.textStyle14.copyWith(color: AppColors.primary200),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      ),
      onChanged: onChanged,
      onTap: () {
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
    );
  }
}

/// Bottom sheet لاختيار الدولة.
/// يعرض الاسم حسب لغة التطبيق، والبحث يشتغل بالعربي والإنجليزي معاً.
void showCountryPickerSheet(
  BuildContext context, {
  required String currentCode,
  required ValueChanged<CountryData> onSelected,
}) {
  String searchText = '';
  final arabic = isArabic;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = kSupportedCountries
              .where((c) => c.matchesQuery(searchText))
              .toList();

          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _SearchField(
                    isArabic: arabic,
                    onChanged: (v) =>
                        setModalState(() => searchText = v.trim()),
                  ),
                  Gap(16.h),
                  Text(
                    ctx.tr('choose_country_val'),
                    style: Styles.textStyle18Meduim,
                  ),
                  Gap(10.h),
                  const Divider(),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(ctx.tr('no_results')))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final item = filtered[index];
                              final isSelected = item.code == currentCode;
                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: AppColors.primary50,
                                leading: Text(
                                  item.flag,
                                  style: TextStyle(fontSize: 24.sp),
                                ),
                                title: Text(
                                  item.displayName(arabic),
                                  style: Styles.textStyle16,
                                ),
                                trailing: Text(
                                  item.code,
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.primary600,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(sheetContext);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final bool isArabic;

  const _SearchField({required this.onChanged, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          hintText: context.tr('search_country_hint'),
          hintTextDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          prefixIcon: Icon(Icons.search, color: AppColors.primary300),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
