// import 'package:tayseer/features/settings/data/models/setting_item_model.dart';
// import 'package:tayseer/my_import.dart';

// abstract class SettingsLocalDataSource {
//   Future<List<SettingItemModel>> getSettingsItems();
//   Future<void> updateSwitchValue(String id, bool value);
//   Future<bool> getSwitchValue(String id);
// }

// class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
//   final SharedPreferences sharedPreferences;

//   SettingsLocalDataSourceImpl({required this.sharedPreferences});

//   @override
//   Future<List<SettingItemModel>> getSettingsItems() async {
//     // هذه البيانات يمكن أن تأتي من API أو قاعدة بيانات
//     return [
//       SettingItemModel(
//         id: 'logos',
//         title: 'الشعارات',
//         icon: Icons.emoji_events_outlined,
//         routeName: AppRouter.kLogosSettings,
//       ),
//       SettingItemModel(
//         id: 'edit_profile',
//         title: 'تعديل البيانات الشخصية',
//         icon: Icons.person_outline,
//         routeName: AppRouter.kEditProfile,
//       ),
//       SettingItemModel(
//         id: 'savers',
//         title: 'الحفظة',
//         icon: Icons.save_outlined,
//         routeName: AppRouter.kSavers,
//       ),
//       SettingItemModel(
//         id: 'language',
//         title: 'اللغة',
//         subtitle: 'العربية',
//         icon: Icons.language_outlined,
//         routeName: AppRouter.kLanguageSettings,
//       ),
//       SettingItemModel(
//         id: 'packages',
//         title: 'الباقات',
//         icon: Icons.card_giftcard_outlined,
//         routeName: AppRouter.kPackages,
//       ),
//       SettingItemModel(
//         id: 'archive',
//         title: 'أرشيف',
//         icon: Icons.archive_outlined,
//         routeName: AppRouter.kArchive,
//       ),
//       SettingItemModel(
//         id: 'hide_story',
//         title: 'إخفاء القصة من',
//         icon: Icons.visibility_off_outlined,
//         hasSwitch: true,
//         switchValue: await getSwitchValue('hide_story'),
//         routeName: '',
//       ),
//       SettingItemModel(
//         id: 'appointments',
//         title: 'الواعيد',
//         icon: Icons.calendar_today_outlined,
//         routeName: AppRouter.kAppointments,
//       ),
//       SettingItemModel(
//         id: 'session_settings',
//         title: 'مدة وأسعار الجلسات',
//         icon: Icons.access_time_outlined,
//         routeName: AppRouter.kSessionSettings,
//       ),
//       SettingItemModel(
//         id: 'workshops',
//         title: 'الورشات للحقوق',
//         icon: Icons.workspaces_outlined,
//         routeName: AppRouter.kWorkshops,
//       ),
//       SettingItemModel(
//         id: 'attendances',
//         title: 'الحضورات',
//         icon: Icons.attendance_outlined,
//         routeName: AppRouter.kAttendances,
//       ),
//       SettingItemModel(
//         id: 'invite',
//         title: 'دعوة',
//         icon: Icons.person_add_outlined,
//         routeName: AppRouter.kInvite,
//       ),
//       SettingItemModel(
//         id: 'account_management',
//         title: 'إدارة الحساب',
//         icon: Icons.settings_outlined,
//         routeName: AppRouter.kAccountManagement,
//       ),
//     ];
//   }

//   @override
//   Future<void> updateSwitchValue(String id, bool value) async {
//     await sharedPreferences.setBool('setting_$id', value);
//   }

//   @override
//   Future<bool> getSwitchValue(String id) async {
//     return sharedPreferences.getBool('setting_$id') ?? false;
//   }
// }
