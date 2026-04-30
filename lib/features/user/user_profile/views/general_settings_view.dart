import 'package:tayseer/core/widgets/custom_error_view.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/email_edit_screen.dart';
import 'package:tayseer/features/user/user_profile/views/phone_edit_screen.dart';
import 'package:tayseer/features/user/user_profile/views/age_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/privacy_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/general_settings/settings_row_item.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/general_settings/settings_section_container.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/general_settings/settings_skeleton.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/general_settings/settings_switch_row.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
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
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  buildWhen: (prev, curr) {
                    if (prev.runtimeType != curr.runtimeType) return true;
                    if (prev is SettingsLoaded && curr is SettingsLoaded) {
                      return prev.userProfile != curr.userProfile;
                    }
                    return true;
                  },
                  builder: (context, state) {
                    if (state is SettingsLoading || state is SettingsInitial) {
                      return const SettingsSkeleton();
                    }
                    if (state is SettingsError) {
                      return CustomErrorView(
                        message: state.message,
                        onRetry: () =>
                            context.read<UserProfileCubit>().refresh(),
                      );
                    }
                    final userProfile = state is SettingsLoaded
                        ? state.userProfile
                        : null;
                    return _buildContent(context, userProfile);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProfileModel? userProfile) {
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

  Widget _buildPersonalSection(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    return SettingsSectionContainer(
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
            if (!mounted) return;
            if (result != null && userProfile != null) {
              await context.read<UserProfileCubit>().updateAge(
                int.parse(result),
              );
            }
          },
          child: SettingsRowItem(
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
            if (!mounted) return;
            context.read<UserProfileCubit>().fetchUserProfile();
          },
          child: SettingsRowItem(label: context.tr('email'), value: ''),
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
            if (!mounted) return;
            context.read<UserProfileCubit>().fetchUserProfile();
          },
          child: SettingsRowItem(
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
    // ✅ أخفي زر تغيير الوضع لو أنثى ومتزوجة
    final hideMarriageToggle =
        kCurrentUserData?.gender == 'female' &&
        (kCurrentUserData?.socialStatus == 'F_social_married' ||
            kCurrentUserData?.socialStatus == 'F_social_married');

    return SettingsSectionContainer(
      title: context.tr('privacy'),
      children: [
        
        // ✅ زر تفعيل/إيقاف قسم الزواج — نفس لوجك الزر في البروفايل
        if (!hideMarriageToggle)
          BlocBuilder<UserProfileCubit, UserProfileState>(
            buildWhen: (prev, curr) {
              if (prev is SettingsLoaded && curr is SettingsLoaded) {
                return prev.isMarriageSectionDeactivated !=
                    curr.isMarriageSectionDeactivated;
              }
              return false;
            },
            builder: (context, state) {
              final isDeactivated = state is SettingsLoaded
                  ? state.isMarriageSectionDeactivated
                  : false;
              return SettingsSwitchRow(
                label: context.tr('deactivate_the_marriage_section'),
                value: isDeactivated,
                onChanged: (value) {
                  _showDeactivateMarriageDialog(context, value);
                },
              );
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
            if (!mounted) return;
            if (result != null && userProfile != null) {
              await context.read<UserProfileCubit>().toggleAnonymousStatus(
                result == "hidden",
              );
            }
          },
          child: SettingsRowItem(
            label: context.tr('who_can_see_my_profile'),
            value: context.tr(_getPrivacyStatus(userProfile?.isAnonymous)),
          ),
        ),
        InkWell(
          onTap: () async {
            final currentStatus = _getProfilePicStatus(userProfile?.imageBlur);
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
            if (!mounted) return;
            if (result != null) {
              await context.read<UserProfileCubit>().updateImageBlur(
                result == "blur_val",
              );
            }
          },
          child: SettingsRowItem(
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
            if (!mounted) return;
            if (result != null && userProfile != null) {
              await context.read<UserProfileCubit>().toggleAnonymousStatus(
                result == "hide_val",
              );
            }
          },
          child: SettingsRowItem(
            label: context.tr('contacts'),
            value: context.tr(_getContactsStatus(userProfile?.isAnonymous)),
          ),
        ),
        SettingsSwitchRow(
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

  String _getPrivacyStatus(bool? isAnonymous) =>
      (isAnonymous ?? false) ? 'hidden' : 'everyone';

  String _getProfilePicStatus(bool? imageBlur) =>
      (imageBlur ?? false) ? 'blur_val' : 'show_val';

  String _getContactsStatus(bool? isAnonymous) =>
      (isAnonymous ?? false) ? 'hide_val' : 'appear_val';

  void _showDeactivateMarriageDialog(BuildContext context, bool value) {
    final overlay = Overlay.of(context);
    final icon = value ? AssetsData.consultationIcon : AssetsData.ringIcon;
    CustomshowDialogWithImage(
      context,
      title: context.tr(
        value ? 'deactivate_marriage_title' : 'activate_marriage_title',
      ),
      supTitle: context.tr('activate_marriage_subtitle'),
      imageUrl: AssetsData.marriageRingIcon,
      bottonText: context.tr('yes'),
      cancelText: context.tr('no'),
      showCancelButton: true,
      onPressed: () {
        NavAnimationService.instance.flyIcon(
          fromContext: context,
          iconAsset: icon,
          overlay: overlay,
          onComplete: () => context.read<UserProfileCubit>().updateSwitch(
            'deactivate_the_marriage_section',
            value,
          ),
        );
      },
      onCancel: () {},
    );
  }
}
