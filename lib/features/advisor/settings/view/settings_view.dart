import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AdvisorBackground(child: _buildBody(context)),
      ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 105.h,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsData.homeBarBackgroundImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // الخلفية فقط للجزء العلوي
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Gap(16.h),
                      SimpleAppBar(title: 'الاعدادات'),
                    ],
                  ),
                ),
              ),

              // القائمة الرئيسية
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // خلفية شفافة
                  ),
                  child: Column(
                    children: [
                      // قائمة الإعدادات
                      Expanded(
                        child: _buildSettingsList(context, state.settings),
                      ),

                      // زر تسجيل الخروج - بدون مساحات زائدة
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ],
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
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 16.h,
        right: 20.w,
        left: 20.w,
      ),
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
    final isNotificationsItem = setting.id == 'notifications';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isNotificationsItem
              ? null
              : () => _handleSettingTap(context, setting),
          borderRadius: BorderRadius.circular(16.r),
          // splashColor: isNotificationsItem
          //     ? Colors.transparent,
          highlightColor: isNotificationsItem ? Colors.transparent : null,
          child: Container(
            padding: isNotificationsItem
                ? EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w)
                : EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  padding: EdgeInsets.all(13.w),
                  child: AppImage(setting.iconAsset),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.title,
                        style: Styles.textStyle16Meduim.copyWith(
                          color: isNotificationsItem
                              ? AppColors.secondary800.withOpacity(0.9)
                              : AppColors.secondary800,
                        ),
                      ),
                    ],
                  ),
                ),

                if (setting.hasSwitch)
                  IgnorePointer(
                    ignoring: false,
                    child: Transform.scale(
                      scaleX: -1,
                      scaleY: 1,
                      child: CupertinoSwitch(
                        value: setting.switchValue,
                        activeColor: const Color(0xFFF06C88),
                        trackColor: AppColors.dropDownArrow,
                        onChanged: (value) {
                          final cubit = context.read<SettingsCubit>();
                          cubit.updateSwitch(setting.id, value, context);
                        },
                      ),
                    ),
                  )
                else
                  _buildTrailingWidget(setting),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(SettingItemModel setting) {
    if (setting.id == 'invite' || setting.id == 'account_management') {
      return const SizedBox(width: 0);
    }

    return setting.subtitle != null
        ? Row(
            children: [
              Text(
                setting.subtitle!,
                style: Styles.textStyle16.copyWith(color: AppColors.secondary),
              ),
              Gap(4.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 18.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 18.w);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 50.w, right: 50.w, bottom: 30.h),
      child: InkWell(
        onTap: () => _showLogoutConfirmation(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.kRedColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.kRedColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.kRedColor,
                size: 22.w,
              ),
              SizedBox(width: 8.w),
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
      onCancel: () {},
    );
  }

  void _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );

    try {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic("all");
      } catch (e) {
        debugPrint('⚠️ Error unsubscribing from topics: $e');
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      showSafeSnackBar(
        context: context,
        text: 'تم تسجيل الخروج بنجاح',
        isSuccess: true,
      );
    } catch (e) {
      Navigator.pop(context);
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ أثناء تسجيل الخروج',
        isError: true,
      );
    }
  }

  void _handleSettingTap(BuildContext context, SettingItemModel setting) async {
    if (setting.onTap != null) {
      await setting.onTap!();
      return;
    }

    if (setting.routeName.isNotEmpty) {
      if (setting.id == 'language') {
        final result = await Navigator.pushNamed(context, setting.routeName);
        if (result != null && result is String) {
          // النتيجة الآن هي اسم اللغة (العربية، الإنجليزية...)
          context.read<SettingsCubit>().updateLanguage(result, context);
        }
      } else {
        Navigator.pushNamed(context, setting.routeName);
      }
    }
  }
}
