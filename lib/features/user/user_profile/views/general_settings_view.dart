import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/age_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/email_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/gender_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/phone_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/privacy_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class GeneralSettingsView extends StatefulWidget {
  const GeneralSettingsView({super.key});

  @override
  State<GeneralSettingsView> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: AdvisorBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Gap(16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SimpleAppBar(title: 'الإعدادات', isLargeTitle: true),
                  ),
                  Expanded(child: _buildContent(context, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UserProfileState state) {
    if (state is SettingsLoading || state is SettingsInitial) {
      return _buildLoadingSkeleton();
    }

    if (state is SettingsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: AppColors.kRedColor, size: 48.w),
            Gap(16.h),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            ),
            Gap(8.h),
            Text(
              (state).message,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () => context.read<UserProfileCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
      );
    }

    if (state is SettingsLoaded) {
      final userProfile = state.userProfile;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            Gap(30.h),
            _buildPersonalSection(context, userProfile),
            Gap(30.h),
            _buildPrivacySection(context, userProfile),
            Gap(40.h),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Gap(30.h),
          _buildSectionSkeleton(title: "المعلومات الشخصية"),
          Gap(30.h),
          _buildSectionSkeleton(title: "الخصوصية"),
          Gap(40.h),
        ],
      ),
    );
  }

  Widget _buildSectionSkeleton({required String title}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, right: 16.w, bottom: 8.h),
            child: Container(
              width: 120.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Gap(16.h),
          for (var i = 0; i < 4; i++) ...[
            _buildSettingRowSkeleton(),
            if (i < 3)
              Divider(
                height: 1.h,
                color: Colors.grey.shade200,
                indent: 15,
                endIndent: 15,
              ),
            Gap(10.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingRowSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 150.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          const Spacer(),
          Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          Gap(10.w),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, right: 16.w, bottom: 8.h),
            child: Text(title, style: Styles.textStyle16Meduim),
          ),
          Gap(16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPersonalSection(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    return _buildSectionContainer(
      title: "المعلومات الشخصية",
      children: [
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AgeSelectionView(initialAge: userProfile?.age ?? 18),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.updateAge(int.parse(result), context);
            }
          },
          child: _buildSettingRow(
            label: "السن",
            value: userProfile?.age.toString() ?? '0',
          ),
        ),
        InkWell(
          onTap: () async {
            final currentGender = _getGenderDisplayText(userProfile?.gender);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GenderSelectionView(initialGender: currentGender),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.updateGender(result, context);
            }
          },
          child: _buildSettingRow(
            label: "النوع",
            value: _getGenderDisplayText(userProfile?.gender),
          ),
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmailEditView()),
            );
          },
          child: _buildSettingRow(
            label: "البريد الالكتروني",
            value: '',
            // value: userProfile?.email?.isNotEmpty == true
            //     ? userProfile!.email!
            //     : 'غير محدد',
          ),
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhoneEditView()),
            );
          },
          child: _buildSettingRow(
            label: "رقم الهاتف",
            value: '',
            // value: userProfile?.phone?.isNotEmpty == true
            //     ? userProfile!.phone!
            //     : 'غير محدد',
            isLast: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    return _buildSectionContainer(
      title: "الخصوصية",
      children: [
        _buildSwitchRow(
          label: "إيقاف الزواج",
          value: !(userProfile?.availableForMarry ?? false),
          onChanged: (value) async {
            final cubit = context.read<UserProfileCubit>();
            await cubit.toggleMarriageStatus(!value, context);
          },
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getPrivacyStatus(userProfile?.isAnonymous);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: "من يمكنه رؤية ملفك الشخصي",
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": "إظهار ملفى للجميع",
                      "subtitle": "سيظهر ملفك الشخصي وصورك لجميع المستخدمين",
                      "value": "الجميع",
                    },
                    {
                      "title": "إخفاء ملفى عن الجميع",
                      "subtitle":
                          "لن يتمكن احد من مستخدمي التطبيق من رؤية ملفك",
                      "value": "مخفي",
                    },
                  ],
                ),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.toggleAnonymousStatus(result == "مخفي", context);
            }
          },
          child: _buildSettingRow(
            label: "من يمكنه رؤية ملفك الشخصي",
            value: _getPrivacyStatus(userProfile?.isAnonymous),
          ),
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getProfilePicStatus(
              userProfile?.isAnonymous,
            );
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: "رؤية صورة الملف الشخصي",
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": "عرض الصورة الشخصية",
                      "subtitle": "سيظهر ملفك الشخصي وصورك لجميع المستخدمين",
                      "value": "عرض",
                    },
                    {
                      "title": "تمويه صورتي عن الجميع",
                      "subtitle":
                          "لن يتمكن احد من مستخدمي التطبيق من رؤية صورتك",
                      "value": "تمويه",
                    },
                  ],
                ),
              ),
            );

            if (result != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.updateImageBlur(result == "تمويه", context);
            }
          },
          child: _buildSettingRow(
            label: "رؤية صورة الملف الشخصي",
            value: _getProfilePicStatus(userProfile?.isAnonymous),
          ),
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getContactsStatus(userProfile?.isAnonymous);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: "اخفاء ملفك الشخصي عن جهات اتصالك",
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": "اخفاء الملف الشخصي",
                      "subtitle": "لن يرى أحد من جهات اتصالك ملفك الشخصي",
                      "value": "إخفاء",
                    },
                    {
                      "title": "اظهار الملف الشخصي",
                      "subtitle": "سيظهر ملفك الشخصي لجهات اتصالك",
                      "value": "إظهار",
                    },
                  ],
                ),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.toggleAnonymousStatus(result == "إخفاء", context);
            }
          },
          child: _buildSettingRow(
            label: "جهات الاتصال",
            value: _getContactsStatus(userProfile?.isAnonymous),
          ),
        ),
        _buildSwitchRow(
          label: "مجهول الهوية",
          value: userProfile?.isAnonymous ?? false,
          onChanged: (value) async {
            final cubit = context.read<UserProfileCubit>();
            await cubit.toggleAnonymousStatus(value, context);
          },
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    String? value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Text(
                label,
                style: Styles.textStyle16.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              if (value != null && value.isNotEmpty) ...[
                Container(
                  constraints: BoxConstraints(maxWidth: 100.w),
                  child: Text(
                    value,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
              Gap(10.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1.h,
            color: Colors.grey.shade200,
            indent: 15,
            endIndent: 15,
          ),
        Gap(10.h),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Gap(10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                label,
                style: Styles.textStyle16.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              IgnorePointer(
                ignoring: false,
                child: Transform.scale(
                  scaleX: -0.8,
                  scaleY: 0.8,
                  child: CupertinoSwitch(
                    value: value,
                    activeColor: const Color(0xFFF06C88),
                    trackColor: AppColors.dropDownArrow,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            indent: 15,
            endIndent: 15,
          ),
        Gap(10.h),
      ],
    );
  }

  String _getGenderDisplayText(String? gender) {
    if (gender == null) return '';
    return gender == 'male' ? 'ذكر' : 'أنثى';
  }

  String _getPrivacyStatus(bool? isAnonymous) {
    if (isAnonymous == null) return 'الجميع';
    return isAnonymous ? 'مخفي' : 'الجميع';
  }

  String _getProfilePicStatus(bool? isAnonymous) {
    if (isAnonymous == null) return 'الجميع';
    return isAnonymous ? 'تمويه' : 'عرض';
  }

  String _getContactsStatus(bool? isAnonymous) {
    if (isAnonymous == null) return 'إخفاء';
    return isAnonymous ? 'إخفاء' : 'إظهار';
  }
}
