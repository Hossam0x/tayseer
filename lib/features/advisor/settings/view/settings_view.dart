import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/my_import.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: Scaffold(body: AdvisorBackground(child: _buildBody(context))),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, SettingsState state) {
    if (state is SettingsLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary100),
      );
    }

    if (state is SettingsError) {
      return Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(20.h),
              Text(
                state.message,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.kWhiteColor,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(20.h),
              ElevatedButton(
                onPressed: () => context.read<SettingsCubit>().refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: Styles.textStyle16Meduim.copyWith(
                    color: AppColors.kWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is SettingsLoaded) {
      return Stack(
        children: [
          // الخلفية فقط للجزء العلوي
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110.h,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsData.homeBarBackgroundImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Gap(16.h),
                  // زر الرجوع مع الخلفية
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.blackColor,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ),

                  // العنوان مع الخلفية
                  Center(
                    child: Text('الإعدادات', style: Styles.textStyle20Bold),
                  ),
                  Gap(8.h),

                  // القائمة + زر تسجيل الخروج
                  Expanded(
                    child: Column(
                      children: [
                        // القائمة الرئيسية
                        Expanded(
                          child: _buildSettingsList(context, state.settings),
                        ),

                        // زر تسجيل الخروج - خارج القائمة
                        Padding(
                          padding: EdgeInsets.only(bottom: 40.h, top: 16.h),
                          child: _buildLogoutButton(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildSettingsList(
    BuildContext context,
    List<SettingItemModel> settings,
  ) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      itemCount: settings.length,
      separatorBuilder: (context, index) =>
          Divider(color: AppColors.secondary100, height: 1),
      itemBuilder: (context, index) {
        final setting = settings[index];
        return _buildSettingItem(context, setting);
      },
    );
  }

  Widget _buildSettingItem(BuildContext context, SettingItemModel setting) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSettingTap(context, setting),
          borderRadius: BorderRadius.circular(16.r),
          splashColor: AppColors.primary100,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48.w,
                  height: 48.w,
                  padding: EdgeInsets.all(13.w),
                  child: AppImage(setting.iconAsset),
                ),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.title,
                        style: Styles.textStyle16Meduim.copyWith(
                          color: AppColors.secondary800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Switch or Arrow
                if (setting.hasSwitch)
                  Transform.scale(
                    scale: 1,
                    child: Switch.adaptive(
                      value: setting.switchValue,
                      onChanged: (value) =>
                          _handleSwitchChange(context, setting, value),
                      inactiveThumbColor: AppColors.primary100,
                      activeTrackColor: AppColors.secondary300,
                      inactiveTrackColor: AppColors.kWhiteColor,
                    ),
                  )
                else
                  setting.subtitle != null
                      ? Row(
                          children: [
                            Text(
                              setting.subtitle!,
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            Gap(4.w),
                            Icon(Icons.arrow_forward_ios_rounded, size: 18.w),
                          ],
                        )
                      : Icon(Icons.arrow_forward_ios_rounded, size: 18.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(context),
          borderRadius: BorderRadius.circular(16.r),
          splashColor: AppColors.kRedColor.withOpacity(0.3),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.kRedColor, width: 1.5),
              gradient: LinearGradient(
                colors: [
                  AppColors.kRedColor.withOpacity(0.1),
                  AppColors.kRedColor.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة تسجيل الخروج
                Container(
                  width: 24.w,
                  height: 24.w,
                  margin: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.kRedColor,
                    size: 22.w,
                  ),
                ),

                // النص
                Text(
                  'تسجيل الخروج',
                  style: Styles.textStyle16Meduim.copyWith(
                    color: AppColors.kRedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: 'تسجيل الخروج',
      supTitle: 'هل أنت متأكد من تسجيل الخروج من حسابك؟',
      imageUrl: AssetsData.icBlockedSettings,
      bottonText: 'نعم، سجل خروج',
      cancelText: 'إلغاء',
      showCancelButton: true,
      onPressed: () {
        _performLogout(context);
      },
      onCancel: () {
        // لا شيء مطلوب - سيتم إغلاق الدايلوج تلقائياً
      },
    );
  }

  void _performLogout(BuildContext context) async {
    // عرض تحميل أثناء تنفيذ العملية
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );

    try {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // عرض رسالة نجاح باستخدام CustomSnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(context, text: 'تم تسجيل الخروج بنجاح', isSuccess: true),
      );
    } catch (e) {
      Navigator.pop(context);

      // عرض رسالة خطأ باستخدام CustomSnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'حدث خطأ أثناء تسجيل الخروج',
          isError: true,
        ),
      );
    }
  }

  void _handleSettingTap(BuildContext context, SettingItemModel setting) async {
    if (setting.onTap != null) {
      setting.onTap!();
      return;
    }

    if (setting.routeName.isNotEmpty) {
      if (setting.id == 'language') {
        final result = await Navigator.pushNamed(context, setting.routeName);
        if (result != null && result is String) {
          context.read<SettingsCubit>().updateLanguage(result);
        }
      } else {
        Navigator.pushNamed(context, setting.routeName);
      }
    }
  }

  void _handleSwitchChange(
    BuildContext context,
    SettingItemModel setting,
    bool value,
  ) {
    context.read<SettingsCubit>().updateSwitch(setting.id, value);

    if (setting.onSwitchChanged != null) {
      setting.onSwitchChanged!(value);
    }

    // إظهار رسالة تأكيد
    if (setting.id == 'hide_story') {
      final message = value ? 'تم تفعيل إخفاء القصة' : 'تم إلغاء إخفاء القصة';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar(context, text: message, isSuccess: value));
    }
  }
}
