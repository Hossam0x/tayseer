import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/my_import.dart';

/// AudioTestWidget - Widget for testing and debugging audio functionality
///
/// Features:
/// - Display AudioService status
/// - Test all sound effects
/// - Control sound settings
/// - Debug information
class AudioTestWidget extends StatefulWidget {
  const AudioTestWidget({super.key});

  @override
  State<AudioTestWidget> createState() => _AudioTestWidgetState();
}

class _AudioTestWidgetState extends State<AudioTestWidget> {
  bool _soundEnabled = true;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = AudioService.instance.soundEffectsEnabled;
      _volume = AudioService.instance.volume;
    });
  }

  Future<void> _toggleSound() async {
    final newValue = !_soundEnabled;
    await AudioService.instance.setSoundEffectsEnabled(newValue);
    setState(() => _soundEnabled = newValue);
  }

  Future<void> _setVolume(double volume) async {
    await AudioService.instance.setVolume(volume);
    setState(() => _volume = volume);
  }

  Future<void> _reinitialize() async {
    await AudioService.instance.dispose();
    await AudioService.instance.initialize();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('audio_test_title')),
        backgroundColor: AppColors.kprimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                    '📊 حالة النظام',
                    style: Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  Gap(16.h),
                  _buildStatusRow(
                    'مُهيأ',
                    AudioService.instance.isInitialized ? 'نعم ✅' : 'لا ❌',
                    AudioService.instance.isInitialized,
                  ),
                  Gap(8.h),
                  _buildStatusRow(
                    'مُفعل',
                    _soundEnabled ? 'نعم ✅' : 'لا ❌',
                    _soundEnabled,
                  ),
                  Gap(8.h),
                  _buildStatusRow(
                    'مستوى الصوت',
                    '${(_volume * 100).round()}%',
                    true,
                  ),
                ],
              ),
            ),

            Gap(24.h),

            // Test Buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                    '🎵 اختبار الأصوات',
                    style: Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  Gap(16.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      _buildTestButton('إعجاب', Icons.favorite, () {
                        AudioService.instance.playLikeSound();
                      }),
                      _buildTestButton(
                        'إلغاء إعجاب',
                        Icons.favorite_border,
                        () {
                          AudioService.instance.playLikeSound(isLiked: false);
                        },
                      ),
                      _buildTestButton('متابعة', Icons.person_add, () {
                        AudioService.instance.playFollowSound();
                      }),
                      _buildTestButton('مشاركة', Icons.share, () {
                        AudioService.instance.playShareSound();
                      }),
                      _buildTestButton('تعليق', Icons.comment, () {
                        AudioService.instance.playCommentSound();
                      }),
                      _buildTestButton('نجاح', Icons.check_circle, () {
                        AudioService.instance.playSuccessSound();
                      }),
                      _buildTestButton('خطأ', Icons.error, () {
                        AudioService.instance.playErrorSound();
                      }),
                      _buildTestButton('نقرة زر', Icons.touch_app, () {
                        AudioService.instance.playButtonTap();
                      }),
                    ],
                  ),
                ],
              ),
            ),

            Gap(24.h),

            // Controls
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                    '⚙️ التحكم',
                    style: Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  Gap(16.h),

                  // Toggle Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('تفعيل الأصوات', style: Styles.textStyle14SemiBold),
                      Switch(
                        value: _soundEnabled,
                        onChanged: (value) => _toggleSound(),
                        activeColor: AppColors.kprimaryColor,
                      ),
                    ],
                  ),

                  Gap(16.h),

                  // Volume Slider
                  Text(
                    'مستوى الصوت: ${(_volume * 100).round()}%',
                    style: Styles.textStyle14SemiBold,
                  ),
                  Gap(8.h),
                  Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppColors.kprimaryColor,
                    onChanged: _setVolume,
                  ),

                  Gap(16.h),

                  // Reinitialize Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reinitialize,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.tr('reinitialize')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kprimaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Gap(24.h),

            // Debug Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🐛 معلومات التشخيص',
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    'للتحقق من عمل الأصوات:\n'
                    '1. تأكد أن "مُهيأ" = نعم ✅\n'
                    '2. تأكد أن "مُفعل" = نعم ✅\n'
                    '3. تأكد من رفع صوت الجهاز\n'
                    '4. تأكد أن الجهاز ليس صامت\n'
                    '5. راجع الـ Console للرسائل',
                    style: Styles.textStyle12.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isGood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Styles.textStyle14.copyWith(color: Colors.grey[700]),
        ),
        Text(
          value,
          style: Styles.textStyle14SemiBold.copyWith(
            color: isGood ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(label, style: Styles.textStyle12SemiBold),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kprimaryColor.withOpacity(0.1),
        foregroundColor: AppColors.kprimaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        elevation: 0,
      ),
    );
  }
}
