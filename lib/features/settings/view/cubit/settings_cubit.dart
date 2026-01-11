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

      final settings = [
        SettingItemModel(
          id: 'logos',
          title: 'الشعارات',
          iconAsset: AssetsData.icNotificationSettings,
          hasSwitch: true,
          routeName: '',
        ),
        SettingItemModel(
          id: 'edit_profile',
          title: 'تعديل البيانات الشخصية',
          iconAsset: AssetsData.icEditSettings,
          routeName: AppRouter.kEditPersonalDataView,
        ),
        SettingItemModel(
          id: 'savers',
          title: 'المحفظه',
          iconAsset: AssetsData.icWalletSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'language',
          title: 'اللغة',
          subtitle: 'عربي',
          iconAsset: AssetsData.icLanguageSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'packages',
          title: 'الباقات',
          iconAsset: AssetsData.icPackesSettinngs,
          routeName: '',
        ),
        SettingItemModel(
          id: 'archive',
          title: 'أرشيف',
          iconAsset: AssetsData.icArchiveSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'hide_story',
          title: 'إخفاء القصة من',
          iconAsset: AssetsData.icHideSettings,

          switchValue: prefs.getBool('setting_hide_story') ?? false,
          routeName: '',
        ),
        SettingItemModel(
          id: 'appointments',
          title: 'الواعيد',
          iconAsset: AssetsData.icDatesSettings,
          routeName: '',
        ),
        SettingItemModel(
          id: 'session_settings',
          title: 'مدة وأسعار الجلسات',
          iconAsset: AssetsData.icDurationSettings,
          routeName: '',
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
          routeName: '',
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
          routeName: '',
        ),
      ];

      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: 'حدث خطأ في تحميل الإعدادات'));
    }
  }

  Future<void> updateSwitch(String id, bool value) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      // تحديث محلياً أولاً
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
        // إذا فشل الحفظ، نرجع للقيمة السابقة
        final revertedSettings = currentState.settings.map((item) {
          if (item.id == id) {
            return item.copyWith(switchValue: !value);
          }
          return item;
        }).toList();

        emit(SettingsLoaded(settings: revertedSettings));
      }
    }
  }

  void refresh() {
    _loadSettings();
  }
}
