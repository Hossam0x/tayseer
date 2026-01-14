import 'package:tayseer/features/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/settings/view/cubit/settings_state.dart';
import 'package:tayseer/my_import.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(SettingsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved language (fallback to Arabic)
      final savedLanguage = prefs.getString('app_language') ?? 'العربية';

      final settings = [
        SettingItemModel(
          id: 'logos',
          title: 'الشعارات',
          iconAsset: AssetsData.icNotificationSettings,
          hasSwitch: true,
          routeName: '',
          switchValue: prefs.getBool('setting_logos') ?? true,
        ),
        SettingItemModel(
          id: 'edit_profile',
          title: 'تعديل البيانات الشخصية',
          iconAsset: AssetsData.icEditSettings,
          routeName: AppRouter.kEditPersonalDataView,
        ),
        SettingItemModel(
          id: 'savers',
          title: 'المحفظة',
          iconAsset: AssetsData.icWalletSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'language',
          title: 'اللغة',
          subtitle: savedLanguage,
          iconAsset: AssetsData.icLanguageSettings,
          routeName: AppRouter.kLanguageSelectionView,
        ),
        SettingItemModel(
          id: 'packages',
          title: 'الباقات',
          iconAsset: AssetsData.icPackesSettinngs,
          routeName: AppRouter.kPackagesTabView,
        ),
        SettingItemModel(
          id: 'archive',
          title: 'أرشيف',
          iconAsset: AssetsData.icArchiveSettings,
          routeName: AppRouter.kArchiveView,
        ),
        SettingItemModel(
          id: 'hide_story',
          title: 'إخفاء القصة من',
          iconAsset: AssetsData.icHideSettings,
          switchValue: prefs.getBool('setting_hide_story') ?? false,
          routeName: AppRouter.kHideStoryFromView,
        ),
        SettingItemModel(
          id: 'appointments',
          title: 'المواعيد',
          iconAsset: AssetsData.icDatesSettings,
          routeName: AppRouter.kAppointmentsView,
        ),
        SettingItemModel(
          id: 'session_settings',
          title: 'مدة وأسعار الجلسات',
          iconAsset: AssetsData.icDurationSettings,
          routeName: AppRouter.kSessionPricingView,
        ),
        SettingItemModel(
          id: 'workshops',
          title: 'المنشورات المحفوظه',
          iconAsset: AssetsData.icSavedSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'blocks',
          title: 'المحظورات',
          iconAsset: AssetsData.icBlockedSettings,
          routeName: AppRouter.kBlockedUsersView,
        ),
        SettingItemModel(
          id: 'invite',
          title: 'دعوة',
          iconAsset: AssetsData.icInviteSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'account_management',
          title: 'إدارة الحساب',
          iconAsset: AssetsData.icManagementSettings,
          routeName: AppRouter.kAccountManagementView,
        ),
      ];

      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: 'حدث خطأ في تحميل الإعدادات'));
    }
  }

  /// تحديث قيمة switch وتخزينها في SharedPreferences
  Future<void> updateSwitch(String id, bool value) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // تحديث محلي أولاً (optimistic update)
    final updatedSettings = currentState.settings.map((item) {
      if (item.id == id) {
        return item.copyWith(switchValue: value);
      }
      return item;
    }).toList();

    emit(SettingsLoaded(settings: updatedSettings));

    // حفظ في SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setting_$id', value);
    } catch (e) {
      // revert على الفشل (اختياري - يمكنك إزالته إذا لا تريد)
      final revertedSettings = currentState.settings.map((item) {
        if (item.id == id) {
          return item.copyWith(switchValue: !value);
        }
        return item;
      }).toList();

      emit(SettingsLoaded(settings: revertedSettings));
    }
  }

  /// تحديث اللغة المختارة + حفظها + تحديث الـ UI
  Future<void> updateLanguage(String newLanguage) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // حفظ في SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', newLanguage);
    } catch (e) {
      // يمكنك إظهار رسالة خطأ هنا إذا أردت
      return;
    }

    // تحديث القائمة محلياً
    final updatedSettings = currentState.settings.map((item) {
      if (item.id == 'language') {
        return item.copyWith(subtitle: newLanguage);
      }
      return item;
    }).toList();

    emit(SettingsLoaded(settings: updatedSettings));
  }

  /// إعادة تحميل الإعدادات كاملة (refresh)
  void refresh() {
    _loadSettings();
  }
}
