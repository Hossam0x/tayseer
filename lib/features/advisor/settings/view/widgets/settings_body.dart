import 'package:tayseer/features/shared/settings/models/setting_item_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/settings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/referral_share_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_error_view.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/settings/settings_item_widget.dart';
import 'package:tayseer/features/shared/settings/widgets/settings_logout_button.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class SettingsBody extends StatelessWidget {
  final VoidCallback onDataChanged;
  final VoidCallback onLogout;
  final VoidCallback onRateApp;
  final Future<void> Function(BuildContext, SettingItemModel) onSettingTap;

  const SettingsBody({
    super.key,
    required this.onDataChanged,
    required this.onLogout,
    required this.onRateApp,
    required this.onSettingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 105.h,
          child: DecoratedBox(
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
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    SimpleAppBar(title: context.tr('settings_title')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (prev, curr) {
                  if (prev is SettingsLoaded && curr is SettingsLoaded) {
                    return prev.settings != curr.settings;
                  }
                  return true;
                },
                builder: (context, state) {
                  if (state is SettingsError) {
                    return SettingsErrorView(message: state.message);
                  }
                  if (state is SettingsLoaded) {
                    return _SettingsList(
                      state: state,
                      onDataChanged: onDataChanged,
                      onLogout: onLogout,
                      onSettingTap: onSettingTap,
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kprimaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsList extends StatelessWidget {
  final SettingsLoaded state;
  final VoidCallback onDataChanged;
  final VoidCallback onLogout;
  final Future<void> Function(BuildContext, SettingItemModel) onSettingTap;

  const _SettingsList({
    required this.state,
    required this.onDataChanged,
    required this.onLogout,
    required this.onSettingTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
            child: ReferralShareCard(
              points: state.points,
              referralLink: state.referralLink,
              onShare: () => context.read<SettingsCubit>().shareApp(
                context.tr('share_app_message'),
                context.tr('share_app_subject'),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) {
                return Divider(color: AppColors.secondary100, height: 1);
              }
              final item = state.settings[index ~/ 2];
              return SettingsItemWidget(
                setting: item,
                onTap: () => onSettingTap(context, item),
                onDataChanged: onDataChanged,
              );
            }, childCount: state.settings.length * 2),
          ),
        ),
        SliverToBoxAdapter(child: SettingsLogoutButton(onTap: onLogout)),
        SliverToBoxAdapter(child: Gap(30.h)),
      ],
    );
  }
}
