import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/screens/email_edit_screen.dart';
import 'package:tayseer/features/user/user_profile/presentation/screens/phone_edit_screen.dart';
import 'package:tayseer/features/user/user_profile/views/age_selection_view.dart';
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
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SimpleAppBar(
                  title: context.tr('settings'),
                  isLargeTitle: true,
                ),
              ),
              Expanded(
                child: BlocSelector<UserProfileCubit, UserProfileState, UserProfileModel?>(
                  selector: (state) {
                    if (state is SettingsLoaded) return state.userProfile;
                    return null;
                  },
                  builder: (context, userProfile) {
                    final state = context.read<UserProfileCubit>().state;
                    return _buildContent(context, state, userProfile);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserProfileState state,
    UserProfileModel? userProfile,
  ) {
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
              context.tr('error_occurred'),
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
                context.tr('retry'),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

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

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Gap(30.h),
          _buildSectionSkeleton(title: context.tr('personal_info')),
          Gap(30.h),
          _buildSectionSkeleton(title: context.tr('privacy')),
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
            padding: EdgeInsetsDirectional.only(
              top: 16.h,
              start: 16.w,
              bottom: 8.h,
            ),
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
      title: context.tr('personal_info'),
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
              await cubit.updateAge(int.parse(result));
            }
          },
          child: _buildSettingRow(
            label: context.tr('age'),
            value: userProfile?.age.toString() ?? '',
          ),
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EmailEditScreen(initialEmail: userProfile?.email ?? ''),
              ),
            );
            // Silent update: fetch only the profile without emitting SettingsLoading
            if (mounted) {
              context.read<UserProfileCubit>().fetchUserProfile();
            }
          },
          child: _buildSettingRow(label: context.tr('email'), value: ''),
        ),
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PhoneEditScreen(initialPhone: userProfile?.phone ?? ''),
              ),
            );
            // Silent update: fetch only the profile without emitting SettingsLoading
            if (mounted) {
              context.read<UserProfileCubit>().fetchUserProfile();
            }
          },
          child: _buildSettingRow(
            label: context.tr('phone'),
            value: '',
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
      title: context.tr('privacy'),
      children: [
        _buildSwitchRow(
          label: context.tr('stop_marriage'),
          value: !(userProfile?.availableForMarry ?? false),
          onChanged: (value) async {
            final cubit = context.read<UserProfileCubit>();
            await cubit.toggleMarriageStatus(!value);
          },
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getPrivacyStatus(userProfile?.isAnonymous);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: context.tr('who_can_see_my_profile'),
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": context.tr('show_to_all'),
                      "subtitle": context.tr('show_to_all_subtitle'),
                      "value": "everyone",
                    },
                    {
                      "title": context.tr('hide_from_all'),
                      "subtitle": context.tr('hide_from_all_subtitle'),
                      "value": "hidden",
                    },
                  ],
                ),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.toggleAnonymousStatus(result == "hidden");
            }
          },
          child: _buildSettingRow(
            label: context.tr('who_can_see_my_profile'),
            value: context.tr(_getPrivacyStatus(userProfile?.isAnonymous)),
          ),
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getProfilePicStatus(
              userProfile?.imageBlur,
            );
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: context.tr('profile_picture_visibility'),
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": context.tr('show_profile_picture'),
                      "subtitle": context.tr('show_profile_picture_subtitle'),
                      "value": "show_val",
                    },
                    {
                      "title": context.tr('hide_profile_picture'),
                      "subtitle": context.tr('hide_profile_picture_subtitle'),
                      "value": "blur_val",
                    },
                  ],
                ),
              ),
            );

            if (result != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.updateImageBlur(result == "blur_val");
            }
          },
          child: _buildSettingRow(
            label: context.tr('profile_picture_visibility'),
            value: context.tr(_getProfilePicStatus(userProfile?.imageBlur)),
          ),
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getContactsStatus(userProfile?.isAnonymous);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacySelectionView(
                  title: context.tr('hide_profile_from_contacts'),
                  initialValue: currentStatus,
                  options: [
                    {
                      "title": context.tr('hide_profile_from_contacts'),
                      "subtitle": context.tr(
                        'hide_profile_from_contacts_subtitle',
                      ),
                      "value": "hide_val",
                    },
                    {
                      "title": context.tr('show_profile_from_contacts'),
                      "subtitle": context.tr(
                        'show_profile_from_contacts_subtitle',
                      ),
                      "value": "appear_val",
                    },
                  ],
                ),
              ),
            );

            if (result != null && userProfile != null) {
              final cubit = context.read<UserProfileCubit>();
              await cubit.toggleAnonymousStatus(result == "hide_val");
            }
          },
          child: _buildSettingRow(
            label: context.tr('contacts'),
            value: context.tr(_getContactsStatus(userProfile?.isAnonymous)),
          ),
        ),
        _buildSwitchRow(
          label: context.tr('anonymous'),
          value: userProfile?.isAnonymous ?? false,
          onChanged: (value) async {
            final cubit = context.read<UserProfileCubit>();
            await cubit.toggleAnonymousStatus(value);
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

  String _getPrivacyStatus(bool? isAnonymous) {
    if (isAnonymous == null) return 'everyone';
    return isAnonymous ? 'hidden' : 'everyone';
  }

  String _getProfilePicStatus(bool? imageBlur) {
    if (imageBlur == null) return 'show_val'; // Default to shown if null
    return imageBlur ? 'blur_val' : 'show_val';
  }

  String _getContactsStatus(bool? isAnonymous) {
    if (isAnonymous == null) return 'hide_val';
    return isAnonymous ? 'hide_val' : 'appear_val';
  }
}
