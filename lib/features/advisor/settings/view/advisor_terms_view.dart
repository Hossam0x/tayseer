import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/my_import.dart';

/// بيانات تُمرَّر للصفحة عند الانتقال إليها
class AdvisorTermsArgs {
  /// الـ callback اللي بيتنفذ لما يضغط "موافق"
  final VoidCallback onAccept;

  const AdvisorTermsArgs({required this.onAccept});
}

class AdvisorTermsView extends StatelessWidget {
  final AdvisorTermsArgs args;
  const AdvisorTermsView({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PackagesCubit>()..getPackages(),
      child: _AdvisorTermsBody(onAccept: args.onAccept),
    );
  }
}

// ─────────────────────────────────────────────
class _AdvisorTermsBody extends StatelessWidget {
  final VoidCallback onAccept;
  const _AdvisorTermsBody({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 105.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocBuilder<PackagesCubit, PackagesState>(
                  builder: (context, state) {
                    // استخرج بيانات الاشتراك الحالي
                    final currentSub = state.subscriptions
                        .where((s) => s.isCurrentSub)
                        .firstOrNull;

                    final subscriptionType =
                        currentSub?.subscriptionType ?? 'free';
                    final commission = _resolveCommission(
                      currentSub,
                      state.subscriptions,
                    );

                    return Column(
                      children: [
                        Gap(16.h),
                        const _TermsAppBar(),
                        Gap(20.h),
                        Expanded(
                          child: _TermsContent(
                            appInterestPercentage: commission,
                            subscriptionType: subscriptionType,
                            isLoading: state.isLoading,
                          ),
                        ),
                        Gap(12.h),
                        _TermsActions(
                          subscriptionType: subscriptionType,
                          onAccept: () {
                            Navigator.pop(context);
                            onAccept();
                          },
                        ),
                        Gap(24.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يحسب العمولة المناسبة:
  /// - لو مشترك → sessionsAppInterestPercentage بتاع الباقة الحالية
  /// - لو مش مشترك → sessionsAppInterestPercentage بتاع أرخص باقة (free/basic)
  double _resolveCommission(
    NewAdvisorSubModel? currentSub,
    List<NewAdvisorSubModel> all,
  ) {
    if (currentSub != null) {
      return currentSub.sessionsAppInterestPercentage.toDouble();
    }
    // مش مشترك — نعرض العمولة الافتراضية (أعلى قيمة = free)
    // لو الـ API مرجعتش حاجة نرجع 25 كـ fallback
    if (all.isEmpty) return 25.0;
    // نرجع أعلى عمولة (الـ free عادةً أعلى)
    return all
        .map((s) => s.sessionsAppInterestPercentage.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }
}

// ─────────────────────────────────────────────
class _TermsAppBar extends StatelessWidget {
  const _TermsAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Transform.flip(
            flipX: !isArabic,
            child: Icon(Icons.arrow_back_ios, size: 16),
          ),
        ),
        const Spacer(),
        Text(
          context.tr('terms_and_conditions_title'),
          style: Styles.textStyle18.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const SizedBox(width: 36),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _TermsContent extends StatelessWidget {
  final double appInterestPercentage;
  final String subscriptionType;
  final bool isLoading;

  const _TermsContent({
    required this.appInterestPercentage,
    required this.subscriptionType,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final bool canReduce =
        subscriptionType == 'gold' || subscriptionType == 'ultra';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── بانر العمولة ──
          _CommissionBanner(
            percentage: appInterestPercentage,
            canReduce: canReduce,
            isLoading: isLoading,
          ),
          Gap(20.h),

          // ── البنود ──
          _TermItem(
            number: '١',
            title: context.tr('terms_commission_title'),
            body: context.tr('terms_commission_body'),
            icon: Icons.percent_rounded,
            iconColor: AppColors.kprimaryColor,
          ),
          _TermItem(
            number: '٢',
            title: context.tr('terms_delay_title'),
            body: context.tr('terms_delay_body'),
            icon: Icons.timer_off_outlined,
            iconColor: Colors.orange,
          ),
          _TermItem(
            number: '٣',
            title: context.tr('terms_manipulation_title'),
            body: context.tr('terms_manipulation_body'),
            icon: Icons.gavel_rounded,
            iconColor: Colors.red.shade600,
          ),
          _TermItem(
            number: '٤',
            title: context.tr('terms_signature_title'),
            body: context.tr('terms_signature_body'),
            icon: Icons.draw_outlined,
            iconColor: Colors.purple,
          ),
          _TermItem(
            number: '٥',
            title: context.tr('terms_privacy_title'),
            body: context.tr('terms_privacy_body'),
            icon: Icons.shield_outlined,
            iconColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _CommissionBanner extends StatelessWidget {
  final double percentage;
  final bool canReduce;
  final bool isLoading;

  const _CommissionBanner({
    required this.percentage,
    required this.canReduce,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kprimaryColor.withOpacity(0.12),
            AppColors.kprimaryColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.kprimaryColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.kprimaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('current_commission_label'),
                style: Styles.textStyle12.copyWith(
                  color: AppColors.kprimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(8.h),
          isLoading
              ? SizedBox(
                  height: 32.h,
                  width: 32.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.kprimaryColor,
                  ),
                )
              : Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          if (!isLoading) ...[
            Gap(6.h),
            Text(
              canReduce
                  ? context.tr('commission_reduce_hint')
                  : context.tr('commission_subscribe_hint'),
              textAlign: TextAlign.center,
              style: Styles.textStyle10.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _TermItem extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

  const _TermItem({
    required this.number,
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Styles.textStyle14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Gap(4.h),
                Text(
                  body,
                  style: Styles.textStyle12.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _TermsActions extends StatelessWidget {
  final String subscriptionType;
  final VoidCallback onAccept;

  const _TermsActions({required this.subscriptionType, required this.onAccept});

  bool get _isUltra => subscriptionType == 'ultra';
  bool get _isGold => subscriptionType == 'gold';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زرار الاشتراك/الترقية — مخفي لو ultra
        if (!_isUltra) ...[
          GestureDetector(
            onTap: () {
              if (_isGold) {
                // مشترك gold → روح على Elite مباشرة
                Navigator.pushNamed(
                  context,
                  AppRouter.kPackagesView,
                  arguments: {'initialPage': 2},
                );
              } else {
                // مش مشترك → روح على صفحة الباقات (Pro افتراضي)
                Navigator.pushNamed(context, AppRouter.kPackagesView);
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.kprimaryColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isGold
                        ? Icons.upgrade_rounded
                        : Icons.workspace_premium_outlined,
                    color: AppColors.kprimaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isGold
                        ? context.tr('upgrade_to_reduce_commission')
                        : context.tr('subscribe_to_reduce_commission'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(10.h),
        ],

        // زرار الموافقة
        CustomBotton(
          width: double.infinity,
          height: 54.h,
          useGradient: true,
          title: context.tr('accept_and_continue'),
          onPressed: onAccept,
        ),
      ],
    );
  }
}
