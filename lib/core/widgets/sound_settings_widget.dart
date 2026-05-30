import 'package:flutter/foundation.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/my_import.dart';

/// SoundSettingsWidget - Widget for controlling sound effects settings
///
/// Features:
/// - Toggle sound effects on/off
/// - Volume control slider
/// - Test sound button
/// - Saves preferences automatically
/// - Beautiful UI with app colors and styles
class SoundSettingsWidget extends StatefulWidget {
  const SoundSettingsWidget({super.key});

  @override
  State<SoundSettingsWidget> createState() => _SoundSettingsWidgetState();
}

class _SoundSettingsWidgetState extends State<SoundSettingsWidget> {
  bool _soundEnabled = true;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Add debug info
    if (kDebugMode) {
      print('🔊 SoundSettingsWidget initialized');
      print(
        '   - AudioService initialized: ${AudioService.instance.isInitialized}',
      );
    }
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = AudioService.instance.soundEffectsEnabled;
      _volume = AudioService.instance.volume;
    });

    if (kDebugMode) {
      print('🔊 Settings loaded: enabled=$_soundEnabled, volume=$_volume');
    }
  }

  Future<void> _toggleSound(bool enabled) async {
    // TODO: re-enable sound toggle when needed
    // await AudioService.instance.setSoundEffectsEnabled(enabled);
    // setState(() => _soundEnabled = enabled);

    // // Play test sound if enabling
    // if (enabled) {
    //   AudioService.instance.playSuccessSound();
    // }
  }

  Future<void> _setVolume(double volume) async {
    await AudioService.instance.setVolume(volume);
    setState(() => _volume = volume);
  }

  void _testSound() {
    // Add debug logging
    if (kDebugMode) {
      print('🔊 Testing sound from SoundSettingsWidget');
      print(
        '   - AudioService initialized: ${AudioService.instance.isInitialized}',
      );
      print(
        '   - Sound effects enabled: ${AudioService.instance.soundEffectsEnabled}',
      );
      print('   - Volume: ${AudioService.instance.volume}');
    }

    AudioService.instance.playSuccessSound();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.kprimaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.kprimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.kprimaryColor,
                  size: 24.sp,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('sound_effects'),
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: AppColors.kprimaryColor,
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      'تحكم في الأصوات والمؤثرات',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.kGreyB3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gap(20.h),

          // Enable/Disable Toggle with enhanced styling
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _soundEnabled
                    ? AppColors.kprimaryColor.withOpacity(0.2)
                    : AppColors.secondary100,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('enable_sound_effects'),
                        style: Styles.textStyle14SemiBold.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        _soundEnabled ? 'الأصوات مُفعلة' : 'الأصوات مُعطلة',
                        style: Styles.textStyle12.copyWith(
                          color: _soundEnabled
                              ? AppColors.kprimaryColor
                              : AppColors.kGreyB3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeColor: AppColors.kprimaryColor,
                  activeTrackColor: AppColors.kprimaryColor.withOpacity(0.3),
                  inactiveThumbColor: AppColors.kGreyB3,
                  inactiveTrackColor: AppColors.secondary100,
                ),
              ],
            ),
          ),

          // Volume control section (only shown when sounds are enabled)
          if (_soundEnabled) ...[
            Gap(20.h),

            // Volume label
            Text(
              context.tr('volume'),
              style: Styles.textStyle14SemiBold.copyWith(color: Colors.black87),
            ),

            Gap(8.h),

            // Volume slider with icons
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.secondary50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_down_rounded,
                    color: AppColors.kGreyB3,
                    size: 20.sp,
                  ),
                  Gap(8.w),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.kprimaryColor,
                        inactiveTrackColor: AppColors.secondary100,
                        thumbColor: AppColors.kprimaryColor,
                        overlayColor: AppColors.kprimaryColor.withOpacity(0.2),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 8.r,
                        ),
                        trackHeight: 4.h,
                      ),
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_volume * 100).round()}%',
                        onChanged: _setVolume,
                      ),
                    ),
                  ),
                  Gap(8.w),
                  Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.kprimaryColor,
                    size: 20.sp,
                  ),
                ],
              ),
            ),

            Gap(8.h),

            // Volume percentage display
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.kprimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${(_volume * 100).round()}%',
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),

            Gap(20.h),

            // Test Sound Button with enhanced styling
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.kprimaryColor,
                      AppColors.kprimaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kprimaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _testSound,
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    context.tr('test_sound'),
                    style: Styles.textStyle14SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 14.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Disabled state message
          if (!_soundEnabled) ...[
            Gap(16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.kGreyB3.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.kGreyB3.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_off_rounded,
                    color: AppColors.kGreyB3,
                    size: 20.sp,
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Text(
                      'الأصوات معطلة حالياً. قم بتفعيلها للاستمتاع بالمؤثرات الصوتية.',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.kGreyB3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick toggle widget for sound effects (for use in app bars, etc.)
class SoundToggleButton extends StatefulWidget {
  const SoundToggleButton({super.key});

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton>
    with SingleTickerProviderStateMixin {
  bool _soundEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _soundEnabled = AudioService.instance.soundEffectsEnabled;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleSound() async {
    // TODO: re-enable sound toggle when needed
    // Animate button press
    await _animationController.forward();
    await _animationController.reverse();

    // final newValue = !_soundEnabled;
    // await AudioService.instance.setSoundEffectsEnabled(newValue);
    // setState(() => _soundEnabled = newValue);

    // // Play test sound if enabling
    // if (newValue) {
    //   AudioService.instance.playSuccessSound();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: _soundEnabled
              ? AppColors.kprimaryColor.withOpacity(0.1)
              : AppColors.kGreyB3.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: IconButton(
          onPressed: _toggleSound,
          icon: Icon(
            _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: _soundEnabled ? AppColors.kprimaryColor : AppColors.kGreyB3,
            size: 24.sp,
          ),
          tooltip: _soundEnabled
              ? context.tr('disable_sound_effects')
              : context.tr('enable_sound_effects'),
        ),
      ),
    );
  }
}
