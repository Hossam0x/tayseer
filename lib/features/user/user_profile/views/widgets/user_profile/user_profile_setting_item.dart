import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserProfileSettingItem extends StatelessWidget {
  final SettingItemModel setting;
  final UserProfileState state;
  final VoidCallback? onEditProfile;
  final void Function(BuildContext, UserProfileState)? onMarriageEdit;
  final void Function(BuildContext, bool)? onMarriageDeactivate;
  final VoidCallback? onRateApp;

  const UserProfileSettingItem({
    super.key,
    required this.setting,
    required this.state,
    this.onEditProfile,
    this.onMarriageEdit,
    this.onMarriageDeactivate,
    this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    final isNotificationsItem = setting.id == 'notifications';
    final isInviteItem = setting.id == 'invite';
    final isRateAppItem = setting.id == 'rate_app';
    final isEditMarriageProfile = setting.id == 'edit_marriage_profile';
    final isDeactiveTheMarriageSection =
        setting.id == 'deactivate_the_marriage_section';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isNotificationsItem || isDeactiveTheMarriageSection) return;
          if (isInviteItem) {
            setting.onTap?.call();
            return;
          }
          if (isRateAppItem) {
            onRateApp?.call();
            return;
          }
          if (isEditMarriageProfile) {
            onMarriageEdit?.call(context, state);
            return;
          }
          if (setting.id == 'settings') {
            final cubit = context.read<UserProfileCubit>();
            Navigator.pushNamed(
              context,
              AppRouter.kGeneralSettingsView,
              arguments: cubit,
            );
          } else if (setting.routeName.isNotEmpty) {
            if (setting.id == 'language') {
              Navigator.pushNamed(context, setting.routeName).then((result) {
                if (result != null && result is String) {
                  context.read<UserProfileCubit>().updateLanguage(result);
                }
              });
            } else {
              Navigator.pushNamed(context, setting.routeName);
            }
          } else {
            onEditProfile?.call();
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        highlightColor: isNotificationsItem || isDeactiveTheMarriageSection
            ? Colors.transparent
            : null,
        child: Container(
          padding: isNotificationsItem || isDeactiveTheMarriageSection
              ? EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w, left: 8.w)
              : EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isEditMarriageProfile
                ? Border.all(color: AppColors.primary200)
                : null,
            color: isEditMarriageProfile
                ? const Color.fromRGBO(235, 122, 145, 0.07)
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
                  context.tr(setting.title),
                  style: Styles.textStyle16Meduim.copyWith(
                    color: isNotificationsItem || isDeactiveTheMarriageSection
                        ? AppColors.secondary800.withOpacity(0.9)
                        : AppColors.secondary800,
                  ),
                ),
              ),
              if (setting.hasSwitch)
                _buildSwitch(context, setting, isDeactiveTheMarriageSection)
              else
                _buildTrailing(context, setting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    SettingItemModel setting,
    bool isDeactivateMarriage,
  ) {
    if (setting.id == 'notifications' || isDeactivateMarriage) {
      return BlocSelector<UserProfileCubit, UserProfileState, bool>(
        selector: (state) {
          if (state is SettingsLoaded) {
            if (setting.id == 'notifications')
              return state.isNotificationEnabled;
            if (isDeactivateMarriage) return state.isMarriageSectionDeactivated;
          }
          return false;
        },
        builder: (context, isEnabled) {
          return _switchWidget(isEnabled, (value) {
            if (setting.id == 'notifications') {
              context.read<UserProfileCubit>().updateSwitch(setting.id, value);
            } else {
              onMarriageDeactivate?.call(context, value);
            }
          });
        },
      );
    }
    return _switchWidget(setting.switchValue, (value) {
      context.read<UserProfileCubit>().updateSwitch(setting.id, value);
    });
  }

  Widget _switchWidget(bool value, ValueChanged<bool> onChanged) {
    return IgnorePointer(
      ignoring: false,
      child: Transform.scale(
        scaleX: -0.9,
        scaleY: 0.9,
        child: CupertinoSwitch(
          value: value,
          activeColor: const Color(0xFFF06C88),
          trackColor: AppColors.dropDownArrow,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, SettingItemModel setting) {
    if (setting.id == 'invite' ||
        setting.id == 'account_management' ||
        setting.id == 'rate_app') {
      return const SizedBox(width: 0);
    }
    return setting.subtitle != null
        ? Row(
            children: [
              Text(
                context.tr(setting.subtitle!),
                style: Styles.textStyle16.copyWith(color: AppColors.secondary),
              ),
              Gap(4.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 16.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 16.w);
  }
}
