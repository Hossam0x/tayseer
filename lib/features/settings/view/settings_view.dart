import 'package:tayseer/features/settings/data/models/setting_item_model.dart';
import 'package:tayseer/features/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/settings/view/cubit/settings_state.dart';
import 'package:tayseer/my_import.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: Scaffold(
        body: SafeArea(child: AdvisorBackground(child: _buildBody(context))),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Gap(20.h),
            Text(
              state.message,
              style: Styles.textStyle16.copyWith(color: AppColors.kWhiteColor),
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
      return Column(
        children: [
          Gap(16.h),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_back, color: AppColors.blackColor),
              ),
            ),
          ),
          Text('الإعدادات', style: Styles.textStyle20Bold),
          Expanded(child: _buildSettingsList(context, state.settings)),
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
      padding: EdgeInsets.only(top: 16.h, bottom: 40.h),
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
                  padding: EdgeInsets.all(10.w),
                  child: AppImage(setting.iconAsset),
                ),

                Gap(16.w),

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

  void _handleSettingTap(BuildContext context, SettingItemModel setting) {
    if (setting.onTap != null) {
      setting.onTap!();
      return;
    }

    if (setting.routeName.isNotEmpty) {
      Navigator.pushNamed(context, setting.routeName);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'تم تفعيل إخفاء القصة' : 'تم إلغاء إخفاء القصة',
            style: Styles.textStyle14.copyWith(color: AppColors.kWhiteColor),
          ),
          backgroundColor: value ? Colors.green : AppColors.secondary600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
