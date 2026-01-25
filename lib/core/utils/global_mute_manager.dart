// lib/core/utils/global_mute_manager.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مدير الـ Mute العام للتطبيق - زي فيسبوك
/// لما تعمل mute لأي فيديو، كل الفيديوهات هتتأثر
class GlobalMuteManager {
  static final GlobalMuteManager instance = GlobalMuteManager._internal();
  
  GlobalMuteManager._internal();

  // ✅ ValueNotifier عشان كل الفيديوهات تسمع للتغييرات
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(true); // Default muted زي فيسبوك
  
  static const String _muteKey = 'global_mute_state';

  /// تحميل حالة الـ Mute المحفوظة
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getBool(_muteKey);
      if (savedState != null) {
        isMuted.value = savedState;
      }
      debugPrint('🔊 GlobalMuteManager initialized: ${isMuted.value ? "Muted" : "Unmuted"}');
    } catch (e) {
      debugPrint('❌ Error loading mute state: $e');
    }
  }

  /// تبديل حالة الـ Mute
  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await _saveState();
    debugPrint('🔊 Global Mute toggled: ${isMuted.value ? "Muted" : "Unmuted"}');
  }

  /// تعيين حالة معينة
  Future<void> setMute(bool muted) async {
    if (isMuted.value != muted) {
      isMuted.value = muted;
      await _saveState();
      debugPrint('🔊 Global Mute set to: ${muted ? "Muted" : "Unmuted"}');
    }
  }

  /// حفظ الحالة
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_muteKey, isMuted.value);
    } catch (e) {
      debugPrint('❌ Error saving mute state: $e');
    }
  }
}