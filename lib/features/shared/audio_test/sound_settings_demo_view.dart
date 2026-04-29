import 'package:tayseer/core/widgets/sound_settings_widget.dart';
import 'package:tayseer/my_import.dart';

/// SoundSettingsDemoView - Demo page for the SoundSettingsWidget
class SoundSettingsDemoView extends StatelessWidget {
  const SoundSettingsDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sound_settings_title')),
        backgroundColor: AppColors.kprimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Demo description
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.secondary50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.kprimaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 عرض توضيحي',
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'هذا عرض توضيحي لويدجت إعدادات الأصوات. يمكنك تجربة جميع الميزات هنا.',
                    style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Gap(24.h),

            // Sound Settings Widget
            const SoundSettingsWidget(),

            Gap(24.h),

            // Quick toggle button demo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kprimaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎛️ زر التحكم السريع',
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    'يمكن استخدام هذا الزر في شريط التطبيق للتحكم السريع:',
                    style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
                  ),
                  Gap(16.h),
                  const Center(child: SoundToggleButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
