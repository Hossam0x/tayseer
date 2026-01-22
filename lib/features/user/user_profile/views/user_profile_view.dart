import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileCubit(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // الخلفية الكاملة في الخلف
            Positioned.fill(
              child: Image.asset(
                AssetsData.homeBarBackgroundImage,
                fit: BoxFit.cover,
              ),
            ),

            // المحتوى فوق الخلفية
            AdvisorBackground(
              child: BlocBuilder<UserProfileCubit, UserProfileState>(
                builder: (context, state) {
                  return _buildBodyContent(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, UserProfileState state) {
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
                onPressed: () => context.read<UserProfileCubit>().refresh(),
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
      return Column(
        children: [
          // التبويب الثابت في الأعلى
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 20.w,
              right: 20.w,
            ),
            child: Column(
              children: [
                CustomToggleTabBar(
                  firstTabText: "عام",
                  secondTabText: "زواج",
                  initialIndex: _selectedTabIndex,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),

                Gap(18.h),

                // صورة وبيانات المستخدم (تظهر فقط في التبويب "عام")
                if (_selectedTabIndex == 0) ...[
                  _buildProfileImage(),
                  Gap(9.h),
                  _buildUserInfo(),
                  Gap(20.h),
                ],
              ],
            ),
          ),

          // القائمة القابلة للتمرير
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: _selectedTabIndex == 0
                  ? _buildGeneralContent(context, state.settings)
                  : _buildMarriageContent(),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildProfileImage() {
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary100,
              image: DecorationImage(
                image: AssetImage(AssetsData.avatarImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          "Dr / Anna Mary",
          style: Styles.textStyle24Bold.copyWith(color: AppColors.blueText),
        ),
        Gap(4.h),
        Text(
          "@annanoo",
          style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.navigateIcon, width: 12.w),
            Gap(10.w),
            Text(
              "عرض الملف الشخصي",
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondary600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralContent(
    BuildContext context,
    List<SettingItemModel> settings,
  ) {
    return Column(
      children: [
        // قائمة الإعدادات
        _buildSettingsList(context, settings),

        // زر تسجيل الخروج
        _buildLogoutButton(context),

        // مساحة إضافية في الأسفل
        Gap(40.h),
      ],
    );
  }

  Widget _buildMarriageContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 80.w,
              color: AppColors.secondary400,
            ),
            Gap(16.h),
            Text(
              "غير مفعل حاليا",
              style: Styles.textStyle20Bold.copyWith(
                color: AppColors.secondary600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    List<SettingItemModel> settings,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          for (var i = 0; i < settings.length; i++) ...[
            _buildSettingItem(context, settings[i]),
            if (i < settings.length - 1)
              Divider(color: AppColors.secondary100, height: 1),
          ],
        ],
      ),
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
          highlightColor: isNotificationsItem ? Colors.transparent : null,
          child: Container(
            padding: isNotificationsItem
                ? EdgeInsets.only(
                    top: 12.h,
                    bottom: 12.h,
                    right: 12.w,
                    left: 8.w,
                  )
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
                      scaleX: -0.9,
                      scaleY: 0.9,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

                          return Transform.scale(
                            scale: scaleFactor,
                            child: CupertinoSwitch(
                              value: setting.switchValue,
                              activeColor: const Color(0xFFF06C88),
                              trackColor: AppColors.dropDownArrow,
                              onChanged: (value) {
                                final cubit = context.read<UserProfileCubit>();
                                cubit.updateSwitch(setting.id, value, context);
                              },
                            ),
                          );
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
    if (setting.id == 'invite' ||
        setting.id == 'account_management' ||
        setting.id == 'rate_app') {
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
              Icon(Icons.arrow_forward_ios_rounded, size: 16.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 16.w);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 50.w, right: 50.w, top: 32.h, bottom: 30.h),
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
          context.read<UserProfileCubit>().updateLanguage(result, context);
        }
      } else {
        Navigator.pushNamed(context, setting.routeName);
      }
    }
  }
}
