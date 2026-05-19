import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserPackageDetailsView extends StatelessWidget {
  final PackageType packageType;
  const UserPackageDetailsView({super.key, required this.packageType});

  @override
  Widget build(BuildContext context) {
    return _UserPackageDetailsContent(packageType: packageType);
  }
}

class _UserPackageDetailsContent extends StatelessWidget {
  final PackageType packageType;
  const _UserPackageDetailsContent({required this.packageType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<UserPackagesCubit, UserPackagesState>(
                builder: (context, state) {
                  final targetType = packageType == PackageType.pro
                      ? 'gold'
                      : 'ultra';
                  // Pick monthly sub for display, fallback to any
                  final subs = state.subscriptions
                      .where((s) => s.subscriptionType == targetType)
                      .toList();
                  final sub =
                      subs.where((s) => s.isMonthly).firstOrNull ??
                      subs.firstOrNull;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Gap(20.h),
                        Text(
                          context.tr('enjoy_more_benefits'),
                          textAlign: TextAlign.center,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary600,
                          ),
                        ),
                        Gap(40.h),
                        _buildFeaturesList(context, sub),
                        Gap(40.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final title = packageType == PackageType.elite
        ? '${context.tr('subscribe_in')} ${context.tr('elite_package')}'
        : '${context.tr('subscribe_in')} ${context.tr('pro_package')}';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SimpleAppBar(title: title, isLargeTitle: true),
    );
  }

  Widget _buildFeaturesList(BuildContext context, NewUserSubModel? sub) {
    final features = _buildFeatures(context, sub);
    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: _buildFeatureItem(context, f['title']!, f['desc']!),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
  ) {
    final checkColors = packageType == PackageType.elite
        ? const [Color(0xFFFFBA40), Color(0xFFFF009F)]
        : const [Color(0xFFBD8F14), Color(0xFFF5C003)];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: checkColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: SvgPicture.asset(
            AssetsData.checkPackageItems,
            width: 24.w,
            height: 24.h,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.secondary800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description.isNotEmpty) ...[
                Gap(4.h),
                Text(
                  description,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary600,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, NewUserSubModel? sub) {
    final isElite = packageType == PackageType.elite;
    final gradientColors = isElite
        ? const [Color(0xFFFFBA40), Color(0xFFFF009F)]
        : const [Color(0xFFBD8F14), Color(0xFFF5C003)];

    final price = sub?.price?.toString() ?? '';
    final currency = sub?.currency ?? '';
    final buttonText = isElite
        ? (price.isNotEmpty
              ? context
                    .tr('subscribe_vip_for')
                    .replaceFirst('{}', price)
                    .replaceFirst('{currency}', currency)
              : '${context.tr('subscribe_in')} ${context.tr('elite_package')}')
        : (price.isNotEmpty
              ? context
                    .tr('get_all_benefits_for')
                    .replaceFirst('{}', price)
                    .replaceFirst('{currency}', currency)
              : '${context.tr('subscribe_in')} ${context.tr('pro_package')}');

    return Center(
      child: Container(
        width: 360.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: isElite ? Alignment.topCenter : Alignment.centerLeft,
            end: isElite ? Alignment.bottomCenter : Alignment.centerRight,
          ),
          border: isElite ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: isElite
              ? [
                  BoxShadow(
                    color: const Color(0xFF6284FF).withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRouter.kUserSubscriptionView,
            arguments: isElite ? SelectedPackage.elite : SelectedPackage.pro,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
          ),
          child: Text(
            buttonText,
            style: Styles.textStyle18SemiBold.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _buildFeatures(
    BuildContext context,
    NewUserSubModel? sub,
  ) {
    if (packageType == PackageType.basic) {
      return [
        {'title': context.tr('limited_number_of_likes'), 'desc': ''},
        {'title': context.tr('you_cannot_see_who_liked'), 'desc': ''},
        {'title': context.tr('there_are_no_free_boosts'), 'desc': ''},
      ];
    }

    final chatRooms = sub?.numberOfChatRooms ?? 0;
    final chatMins = sub?.numberOfChatRoomMins ?? 0;
    final greetings = sub?.numberOfDailyGreetings ?? 0;
    final reinforcements = sub?.numberOfFreeWeeklyReinforcements ?? 0;
    final renables = sub?.numberOfFreeMatchingRenables ?? 0;

    return [
      {
        'title': context.tr('unlimited_number_of_likes'),
        'desc': context.tr('you_can_see_who_liked'),
      },
      {
        'title': '$chatRooms ${context.tr('chat_rooms')}',
        'desc': '$chatMins ${context.tr('minutes')}',
      },
      {'title': '$greetings ${context.tr('daily_greetings')}', 'desc': ''},
      {
        'title': '$reinforcements ${context.tr('free_weekly_reinforcements')}',
        'desc': '',
      },
      {
        'title': '$renables ${context.tr('free_matching_renables')}',
        'desc': '',
      },
    ];
  }
}
