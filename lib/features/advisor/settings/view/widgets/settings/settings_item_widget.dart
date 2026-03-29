import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/my_import.dart';

class SettingsItemWidget extends StatelessWidget {
  final SettingItemModel setting;
  final VoidCallback onTap;
  final VoidCallback onDataChanged;

  static const _guestProtectedIds = {
    'events',
    'savers',
    'order_management',
    'packages',
    'archive',
    'hide_story',
    'appointments',
    'workshops',
    'blocks',
  };

  const SettingsItemWidget({
    super.key,
    required this.setting,
    required this.onTap,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isNotificationsItem = setting.id == 'notifications';
    final isGuestProtected = _guestProtectedIds.contains(setting.id);
    final isCustomClickItem =
        isGuestProtected || setting.id == 'session_settings';

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isNotificationsItem || isCustomClickItem ? null : onTap,
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
                  child: Text(
                    context.tr(setting.title),
                    style: Styles.textStyle16Meduim.copyWith(
                      color: isNotificationsItem
                          ? AppColors.secondary800.withOpacity(0.9)
                          : AppColors.secondary800,
                    ),
                  ),
                ),
                if (setting.hasSwitch)
                  _NotificationSwitch(
                    settingId: setting.id,
                    onChanged: onDataChanged,
                  )
                else
                  _TrailingWidget(setting: setting),
              ],
            ),
          ),
        ),
      ),
    );

    if (isCustomClickItem) {
      return CustomClick(onTap: onTap, child: child);
    }
    return child;
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String settingId;
  final VoidCallback onChanged;

  const _NotificationSwitch({required this.settingId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) {
        if (previous is SettingsLoaded && current is SettingsLoaded) {
          return previous.isNotificationEnabled !=
              current.isNotificationEnabled;
        }
        return false;
      },
      builder: (context, state) {
        final isEnabled = state is SettingsLoaded
            ? state.isNotificationEnabled
            : false;
        return Transform.scale(
          scaleX: -1,
          scaleY: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaleFactor = MediaQuery.of(context).size.width > 600
                  ? 1.5
                  : 1.0;
              return Transform.scale(
                scale: scaleFactor,
                child: CupertinoSwitch(
                  value: isEnabled,
                  activeColor: const Color(0xFFF06C88),
                  trackColor: AppColors.dropDownArrow,
                  onChanged: (value) {
                    onChanged();
                    context.read<SettingsCubit>().updateSwitch(
                      settingId,
                      value,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final SettingItemModel setting;

  const _TrailingWidget({required this.setting});

  @override
  Widget build(BuildContext context) {
    if (setting.id == 'invite' || setting.id == 'account_management') {
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
              Icon(Icons.arrow_forward_ios_rounded, size: 18.w),
            ],
          )
        : Icon(Icons.arrow_forward_ios_rounded, size: 18.w);
  }
}
