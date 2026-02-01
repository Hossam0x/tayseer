// features/user/user_profile/views/marriage_profile_page.dart

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/general_settings_view.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_profile_edit_view.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfilePage extends StatefulWidget {
  const MarriageProfilePage({super.key});

  @override
  State<MarriageProfilePage> createState() => _MarriageProfilePageState();
}

class _MarriageProfilePageState extends State<MarriageProfilePage> {
  int _rating = 0;

  // العناصر المسموح بعرضها في صفحة الزواج
  final List<String> _allowedSettingIds = [
    'edit_marriage_profile', // تعديل ملف الزواج
    'settings', // الاعدادات العامة
    'help_support', // المساعدة والدعم
    'invite', // دعوة صديق
    'rate_app', // تقييم التطبيق
    'account_management', // إدارة الحساب
  ];

  // ⭐ إنشاء الإعدادات الخاصة بالزواج
  List<SettingItemModel> _getMarriageSettings(
    List<SettingItemModel> generalSettings,
    bool isNotProfileComplete,
  ) {
    // نسخ الإعدادات المسموح بها من القائمة العامة
    final marriageSettings = generalSettings
        .where((setting) => _allowedSettingIds.contains(setting.id))
        .toList();

    // ⭐⭐⭐ إضافة العنصر الصحيح حسب حالة الاكتمال
    marriageSettings.insert(
      0,
      SettingItemModel(
        id: 'edit_marriage_profile',
        title: isNotProfileComplete ? 'اكمال ملف الزواج' : 'تعديل ملف الزواج',
        iconAsset: AssetsData.icEditSettings,
        routeName: '',
      ),
    );

    return marriageSettings;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        // ⭐⭐⭐ تحديد حالة اكتمال البروفايل
        bool isNotProfileComplete = false;

        if (state is SettingsLoaded && state.userProfile != null) {
          final isCompleted = state.userProfile!.dataCompleted ?? false;

          // لو الداتا مش مكتملة
          isNotProfileComplete = !isCompleted;
        }
        // if (state is SettingsLoaded && state.userProfile != null) {
        //   // نفترض أن البروفايل مكتمل إذا كان avaliableForMarry = true
        //   // يمكنك تعديل هذا الشرط حسب منطق التطبيق
        //   isNotProfileComplete = false;
        // }

        return SliverList(
          delegate: SliverChildListDelegate([
            // ⭐ إضافة البروفايل في الأعلى
            _buildProfileSection(context, state),

            Gap(20.h),

            // ⭐ القائمة - تمرير حالة الاكتمال
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSettingsList(context, state, isNotProfileComplete),
            ),
            Gap(55.h),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              height: 113.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Color(0xFFFFFFFF), // White at top
                    // Color(0xFFFFC0CB),
                    AppColors.kWhiteColor.withOpacity(0.7),
                    AppColors.primary50,
                    AppColors.primary100,

                    // Color(0xFFFFC0CB),

                    // AppColors.secondary200, // Light pink at bottom (primary50/secondary200)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors
                        .secondary300, // Light pink at bottom (primary50/secondary200)

                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "هل تزوجت بواسطة",
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.primary600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Stack(
                              children: [
                                Text(
                                  "تيسير",
                                  style: Styles.textStyle26Bold.copyWith(
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3.w
                                      ..color = Color(
                                        0xFFAC1A36,
                                      ), // RGB(172, 26, 54)
                                  ),
                                ),
                                Text(
                                  "تيسير",
                                  style: Styles.textStyle26Bold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "تواصل معنا واحصل علي مكافأة مالية",
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondary700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      log("تواصل معنا button tapped");
                      // Handle button tap
                    },
                    child: Container(
                      width: 125.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors
                                .primary300, // Light pink at bottom (primary50/secondary200)

                            blurRadius: 11,
                            spreadRadius: 0,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary200, // Your primary color
                            AppColors.primary200, // Your secondary color
                            AppColors.primary100, // Your secondary color
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "تواصل معنا",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  // ⭐ قسم البروفايل (يستخدم UserProfileModel)
  Widget _buildProfileSection(BuildContext context, UserProfileState state) {
    if (state is SettingsInitial || state is SettingsLoading) {
      return _buildProfileSkeleton();
    }

    if (state is SettingsError) {
      return _buildProfileErrorSection(context, state);
    }

    if (state is SettingsLoaded) {
      return _buildProfileLoadedSection(context, state.userProfile);
    }

    return const SizedBox();
  }

  Widget _buildProfileSkeleton() {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary200,
          ),
        ),
        Gap(9.h),
        Container(
          width: 150.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(4.h),
        Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileErrorSection(BuildContext context, SettingsError state) {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary100,
            border: Border.all(color: AppColors.kRedColor, width: 2),
          ),
          child: Center(
            child: Icon(
              Icons.error_outline,
              color: AppColors.kRedColor,
              size: 48.w,
            ),
          ),
        ),
        Gap(12.h),
        Text(
          'فشل تحميل بيانات البروفايل',
          style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileLoadedSection(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    return Column(
      children: [
        _buildProfileImage(userProfile),
        Gap(9.h),
        _buildUserInfo(context, userProfile),
      ],
    );
  }

  Widget _buildProfileImage(UserProfileModel? userProfile) {
    final imageUrl = userProfile?.image;

    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary100,
          image: (imageUrl != null && imageUrl.isNotEmpty)
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Center(
                child: Icon(
                  Icons.person,
                  size: 48.w,
                  color: AppColors.secondary400,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserProfileModel? userProfile) {
    if (userProfile == null) {
      return _buildUserInfoSkeleton();
    }

    return Column(
      children: [
        Text(
          userProfile.name,
          style: Styles.textStyle24Bold.copyWith(color: AppColors.blueText),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        if (userProfile.username.isNotEmpty) ...[
          Gap(4.h),
          Text(
            userProfile.username,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
          ),
        ],
      ],
    );
  }

  Widget _buildUserInfoSkeleton() {
    return Column(
      children: [
        Container(
          width: 150.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(4.h),
        Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12.w, height: 12.w, color: AppColors.secondary200),
            Gap(10.w),
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ⭐⭐⭐ تحديث بناء قائمة الإعدادات لتمرير حالة الاكتمال
  Widget _buildSettingsList(
    BuildContext context,
    UserProfileState state,
    bool isNotProfileComplete,
  ) {
    List<SettingItemModel> settings = [];

    if (state is SettingsLoaded) {
      // ⭐⭐⭐ إنشاء القائمة الخاصة بالزواج مع حالة الاكتمال
      settings = _getMarriageSettings(state.settings, isNotProfileComplete);
    } else if (state is SettingsLoading || state is SettingsInitial) {
      return Column(
        children: [
          for (var i = 0; i < 6; i++) ...[
            _buildSettingItemSkeleton(),
            if (i < 5) Divider(color: AppColors.secondary100, height: 1),
          ],
        ],
      );
    }

    if (settings.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        for (var i = 0; i < settings.length; i++) ...[
          _buildSettingItem(context, settings[i], state, isNotProfileComplete),
          if (i < settings.length - 1)
            Divider(color: AppColors.secondary100, height: 1),
        ],
      ],
    );
  }

  Widget _buildSettingItemSkeleton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Container(
              width: 120.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    SettingItemModel setting,
    UserProfileState state,
    bool isNotProfileComplete,
  ) {
    final isNotificationsItem = setting.id == 'notifications';
    final isInviteItem = setting.id == 'invite';
    final isRateAppItem = setting.id == 'rate_app';
    final isEditMarriageProfile = setting.id == 'edit_marriage_profile';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isNotificationsItem) return;

          if (isInviteItem) {
            setting.onTap?.call();
            return;
          }

          if (isRateAppItem) {
            _showRateAppDialog();
            return;
          }

          // ⭐ معالجة تعديل ملف الزواج
          if (isEditMarriageProfile) {
            _openMarriageEditProfile(context, state);
            return;
          }

          if (setting.id == 'settings' || setting.id == 'general_settings') {
            final cubit = context.read<UserProfileCubit>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: const GeneralSettingsView(),
                ),
              ),
            );
          } else if (setting.routeName.isNotEmpty) {
            Navigator.pushNamed(context, setting.routeName);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        highlightColor: isNotificationsItem ? Colors.transparent : null,
        child: Container(
          padding: isNotificationsItem
              ? EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w, left: 8.w)
              : EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isNotProfileComplete && isEditMarriageProfile
                ? Border.all(color: AppColors.primary200)
                : null,
            color: isNotProfileComplete && isEditMarriageProfile
                ? Color.fromRGBO(235, 122, 145, 0.07)
                : Colors.transparent,
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
                child: Text(
                  setting.title,
                  style: Styles.textStyle16Meduim.copyWith(
                    color: isNotificationsItem
                        ? AppColors.secondary800.withOpacity(0.9)
                        : AppColors.secondary800,
                  ),
                ),
              ),
              if (setting.hasSwitch)
                IgnorePointer(
                  ignoring: false,
                  child: Transform.scale(
                    scaleX: -0.9,
                    scaleY: 0.9,
                    child: CupertinoSwitch(
                      value: setting.switchValue,
                      activeColor: const Color(0xFFF06C88),
                      trackColor: AppColors.dropDownArrow,
                      onChanged: (value) {
                        final cubit = context.read<UserProfileCubit>();
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
    );
  }

  // ⭐ فتح صفحة تعديل ملف الزواج (تمرير UserProfileModel)
  void _openMarriageEditProfile(BuildContext context, UserProfileState state) {
    if (state is! SettingsLoaded || state.userProfile == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // الخلفية الكاملة في الخلف
              Positioned.fill(
                child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
              ),
              AdvisorBackground(
                child: MarriagefilePage(
                  userProfile: state.userProfile, // ⭐ تمرير UserProfileModel
                ),
              ),
            ],
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

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, size: 24.w),
                      ),
                      Text(
                        'قيمنا',
                        style: Styles.textStyle20Meduim.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Gap(24.w),
                    ],
                  ),
                  Gap(25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Icon(
                          Icons.star_rounded,
                          color: index < _rating
                              ? AppColors.kprimaryColor
                              : AppColors.secondary100,
                          size: 56.w,
                        ),
                      );
                    }),
                  ),
                  if (_rating > 0) ...[
                    Gap(12.h),
                    Text(
                      'تقييمك: $_rating / 5',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                  Gap(24.h),
                  Text(
                    'قيمنا حتى نتمكن من تغيير السلبيات\nساعد غيرك في الاستخدام',
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  CustomBotton(
                    title: 'ارسال التقييم',
                    onPressed: () {
                      Navigator.pop(context);
                      _submitAppRating(context, _rating);
                      setState(() {
                        _rating = 0;
                      });
                    },
                    width: double.infinity,
                    height: 54.h,
                    useGradient: true,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitAppRating(BuildContext context, int rating) {
    if (rating > 0) {
      debugPrint('التقييم المرسل: $rating نجوم');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        context,
        text: rating > 0
            ? 'شكراً لتقييمك التطبيق بـ $rating نجوم!'
            : 'شكراً لتقييمك التطبيق!',
        isSuccess: true,
      ),
    );
  }
}
