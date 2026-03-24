import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:tayseer/my_import.dart';

/// A reusable date picker field that respects the current app language direction.
/// [date] is the currently selected date (null shows the hint).
/// [hintKey] is the translation key for the hint text.
/// [onDatePicked] is called when the user picks a date.
class CertificateDatePicker extends StatelessWidget {
  final DateTime? date;
  final String hintKey;
  final ValueChanged<DateTime> onDatePicked;

  const CertificateDatePicker({
    super.key,
    required this.date,
    required this.hintKey,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          locale: isArabic ? const Locale('ar') : const Locale('en'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.kprimaryColor,
                  onPrimary: Colors.white,
                  onSurface: AppColors.secondary800,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onDatePicked(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Row(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          children: [
            AppImage(AssetsData.calenderIcon, width: 22.h),
            SizedBox(
              width: 30,
              height: 20,
              child: VerticalDivider(color: AppColors.primary100, thickness: 2),
            ),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat(
                        'dd MMMM yyyy',
                        isArabic ? 'ar' : 'en',
                      ).format(date!)
                    : context.tr(hintKey),
                style: Styles.textStyle14.copyWith(
                  color: date == null
                      ? AppColors.primary200
                      : AppColors.secondary800,
                ),
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
