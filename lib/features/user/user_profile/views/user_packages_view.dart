import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/domain/use_cases/get_package_display_data.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_background.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_king_icon.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/restore_purchases_button.dart';
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_package_action_button.dart';

class UserPackagesView extends StatelessWidget {
  const UserPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fromPartnerFilter = args?['fromPartnerFilter'] == true;
    final fromOnboarding = args?['fromOnboarding'] == true;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<UserPackagesCubit>()..getPackages(),
        ),
        BlocProvider(create: (context) => PackageSelectionCubit()),
      ],
      child: _UserPackagesViewContent(
        fromPartnerFilter: fromPartnerFilter,
        fromOnboarding: fromOnboarding,
      ),
    );
  }
}

class _UserPackagesViewContent extends StatefulWidget {
  const _UserPackagesViewContent({
    this.fromPartnerFilter = false,
    this.fromOnboarding = false,
  });

  final bool fromPartnerFilter;
  final bool fromOnboarding;

  @override
  State<_UserPackagesViewContent> createState() =>
      _UserPackagesViewContentState();
}

class _UserPackagesViewContentState extends State<_UserPackagesViewContent>
    with TickerProviderStateMixin {
  late PageController _pageController;
  final _getPackageData = GetPackageDisplayData();

  bool _initialPageSet = false;
  int? _expandedSubIndex; // accordion: index of the currently expanded card

  // Animation controllers for balloon effect on tab buttons
  late AnimationController _basicScaleController;
  late AnimationController _proScaleController;
  late Animation<double> _basicScaleAnim;
  late Animation<double> _proScaleAnim;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFadeAnim;
  late Animation<Offset> _entranceSlideAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );

    _basicScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _proScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _basicScaleAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _basicScaleController,
            curve: Curves.easeInOut,
          ),
        );
    _proScaleAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _proScaleController, curve: Curves.easeInOut),
        );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();
    _jumpToCachedPage();
  }

  Future<void> _jumpToCachedPage() async {
    final cached = await UserPackagesCubit.getCachedSubType();
    if (cached != null && mounted) {
      const packages = [PackageType.basic, PackageType.pro];
      final index = packages.indexOf(cached);
      if (index != -1) {
        context.read<PackageSelectionCubit>().selectPackage(cached);
        if (_pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
      }
    }
  }

  void _triggerBalloonFor(PackageType pkg) {
    if (pkg == PackageType.basic) {
      _basicScaleController.forward(from: 0);
    } else if (pkg == PackageType.pro) {
      _proScaleController.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AssetsData.eliteBackgroundPng), context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _basicScaleController.dispose();
    _proScaleController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PackageSelectionCubit, PackageSelectionState>(
          listenWhen: (previous, current) =>
              previous.selectedPackage != current.selectedPackage,
          listener: _onPackageSelectionChanged,
        ),
        BlocListener<UserPackagesCubit, UserPackagesState>(
          listenWhen: (prev, curr) =>
              prev.isLoading && !curr.isLoading && !_initialPageSet,
          listener: (context, state) {
            _initialPageSet = true;
            final cubit = context.read<UserPackagesCubit>();
            final currentPkg = cubit.currentSubscribedPackage;
            if (currentPkg != null && currentPkg != PackageType.elite) {
              const packages = [PackageType.basic, PackageType.pro];
              final index = packages.indexOf(currentPkg);
              if (index != -1) {
                context.read<PackageSelectionCubit>().selectPackage(currentPkg);
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOutCubic,
                  );
                }
              }
            } else if (currentPkg == null) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (!mounted) return;
                context.read<PackageSelectionCubit>().selectPackage(
                  PackageType.pro,
                );
                if (_pageController.hasClients) {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                }
                _triggerBalloonFor(PackageType.pro);
              });
            }
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            const PackageBackground(),
            _buildContent(),
            _buildKingIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child:
                    BlocSelector<
                      PackageSelectionCubit,
                      PackageSelectionState,
                      PackageType
                    >(
                      selector: (state) => state.selectedPackage,
                      builder: (context, selectedPackage) {
                        return IconButton(
                          icon: Transform.flip(
                            flipX: !isArabic,
                            child: SvgPicture.asset(
                              AssetsData.backArrow,
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (widget.fromPartnerFilter) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRouter.kUserLayoutView,
                                (route) => false,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _entranceFadeAnim,
              child: SlideTransition(
                position: _entranceSlideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(flex: 30, child: _buildPageView()),
                    const Spacer(),
                    _buildTabSelector(),
                    _buildActionButton(),
                    Gap(5.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: const AgreementText(),
                    ),
                    if (Platform.isIOS) ...[
                      Gap(2.h),
                      RestorePurchasesButton(
                        textColor: AppColors.kprimaryTextColor,
                      ),
                    ],
                    Gap(10.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const BouncingScrollPhysics(),
      pageSnapping: true,
      itemCount: 2,
      itemBuilder: (context, index) {
        final packageTypes = [PackageType.basic, PackageType.pro];
        return _buildPage(packageTypes[index]);
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PAGE CONTENT
  // ════════════════════════════════════════════════════════════════

  Widget _buildPage(PackageType packageType) {
    return BlocBuilder<UserPackagesCubit, UserPackagesState>(
      buildWhen: (prev, curr) => prev.subscriptions != curr.subscriptions,
      builder: (context, state) {
        final packageData = _getPackageData(
          context: context,
          packageType: packageType,
          apiPackages: state.subscriptions
              .map((s) => s.toAdvisorSubModel())
              .toList(),
        );
        return RepaintBoundary(
          child: Column(
            children: [
              Gap(10.h),
              SizedBox(
                height: 40.h,
                child: _buildPackageTitle(packageData, packageType),
              ),
              Gap(20.h),
              Expanded(
                child: _buildContentSection(context, packageType, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageTitle(
    PackageDisplayModel package,
    PackageType packageType,
  ) {
    switch (packageType) {
      case PackageType.pro:
        return Text(
          package.packageTitle,
          textAlign: TextAlign.center,
          style: Styles.textStyle24Meduim.copyWith(color: Colors.black87),
        );
      case PackageType.basic:
        return Text(
          package.packageTitle,
          textAlign: TextAlign.center,
          style: Styles.textStyle24Bold.copyWith(
            color: const Color(0xFFE91E63),
          ),
        );
      case PackageType.elite:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContentSection(
    BuildContext context,
    PackageType selectedPackage,
    UserPackagesState packagesState,
  ) {
    // Basic: show the benefits icons section
    if (selectedPackage == PackageType.basic) {
      return _buildBenefitsSection(context, selectedPackage);
    }

    // Pro: accordion cards — each card has its own features when expanded
    final subs = packagesState.subscriptions
        .where((s) => s.subscriptionType == 'gold')
        .toList();

    final weekly = subs.where((s) => s.isWeekly).firstOrNull;
    final monthly = subs.where((s) => s.isMonthly).firstOrNull;
    final threeMonths = subs.where((s) => s.isThreeMonths).firstOrNull;

    final orderedSubs = [
      if (weekly != null) weekly,
      if (monthly != null) monthly,
      if (threeMonths != null) threeMonths,
    ];

    if (orderedSubs.isEmpty) {
      final fallback = subs.firstOrNull;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: _buildDurationCard(
          context,
          fallback,
          index: 0,
          isExpanded: true,
          isCurrentSub: fallback?.isCurrentSub ?? false,
        ),
      );
    }

    // Auto-open the current subscription card on first load
    if (_expandedSubIndex == null) {
      final currentIndex = orderedSubs.indexWhere((s) => s.isCurrentSub);
      if (currentIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _expandedSubIndex = currentIndex);
        });
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: List.generate(orderedSubs.length, (i) {
          final sub = orderedSubs[i];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildDurationCard(
              context,
              sub,
              index: i,
              isExpanded: _expandedSubIndex == i,
              isCurrentSub: sub.isCurrentSub,
            ),
          );
        }),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DURATION ACCORDION CARD
  // Each card shows its own 3 features when expanded + "See more" dialog
  // ════════════════════════════════════════════════════════════════

  Widget _buildDurationCard(
    BuildContext context,
    NewUserSubModel? sub, {
    required int index,
    required bool isExpanded,
    required bool isCurrentSub,
  }) {
    const goldGradient = [Color(0xFFBD8F14), Color(0xFFF5C003)];
    const goldLight = Color(0xFFFFF8E5);
    const goldBorder = Color(0xFFE8C547);

    final durationLabel = _getDurationLabel(
      context,
      sub?.subscriptionDurationType,
    );
    final price = sub?.price;
    final pricePerMonth = sub?.pricePerMonth;
    final currency = sub?.currency ?? '';
    final savePercentage = sub?.savePercentage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: isCurrentSub ? const Color(0xFFFFF3CC) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isExpanded
              ? goldBorder
              : isCurrentSub
              ? goldBorder
              : const Color(0xFFEEEEEE),
          width: isExpanded || isCurrentSub ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded || isCurrentSub
                ? const Color(0xFFBD8F14).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: isExpanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row — tap to toggle accordion ──
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedSubIndex = isExpanded ? null : index;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: isCurrentSub || isExpanded
                      ? const LinearGradient(
                          colors: goldGradient,
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        )
                      : null,
                  color: isCurrentSub || isExpanded ? null : goldLight,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            durationLabel,
                            style: Styles.textStyle16SemiBold.copyWith(
                              color: isCurrentSub || isExpanded
                                  ? Colors.white
                                  : const Color(0xFF8B6914),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (pricePerMonth != null) ...[
                            Gap(2.h),
                            Text(
                              '${pricePerMonth.toStringAsFixed(0)} $currency / ${context.tr('month')}',
                              style: Styles.textStyle12.copyWith(
                                color: isCurrentSub || isExpanded
                                    ? Colors.white.withOpacity(0.85)
                                    : const Color(0xFFAA8820),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Gap(8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (price != null)
                          Text(
                            '${price.toStringAsFixed(0)} $currency',
                            style: Styles.textStyle18Bold.copyWith(
                              color: isCurrentSub || isExpanded
                                  ? Colors.white
                                  : const Color(0xFF8B6914),
                            ),
                          ),
                        if (savePercentage != null) ...[
                          Gap(4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentSub || isExpanded
                                  ? Colors.white.withOpacity(0.25)
                                  : const Color(0xFFBD8F14),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '${context.tr('save')} $savePercentage%',
                              style: Styles.textStyle10.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isCurrentSub) ...[
                          Gap(4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              context.tr('current_subscription'),
                              style: Styles.textStyle10.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Gap(8.w),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isCurrentSub || isExpanded
                            ? Colors.white
                            : const Color(0xFF8B6914),
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable body — features + "See more" ──
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: isExpanded
                    ? _buildCardFeaturesBody(
                        context,
                        sub,
                        durationLabel,
                        price,
                        currency,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body rendered inside an expanded card ──
  Widget _buildCardFeaturesBody(
    BuildContext context,
    NewUserSubModel? sub,
    String planLabel,
    num? price,
    String currency,
  ) {
    final allFeatures = _buildAllFeatureItems(context, sub);
    const staticCount = 3;
    final extraCount = allFeatures.length - staticCount;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First 3 features — always visible inside the card
          ...allFeatures
              .take(staticCount)
              .map(
                (f) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildFeatureRow(context, f),
                ),
              ),

          // "See more +N" row
          if (extraCount > 0) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showAllFeaturesDialog(
                context,
                sub: sub,
                planLabel: planLabel,
                price: price,
                currency: currency,
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: const Color(0xFFE8C547).withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr('see_more_features'),
                      style: Styles.textStyle12.copyWith(
                        color: const Color(0xFF8B6914),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6914),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '+$extraCount',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Divider(
                        color: const Color(0xFFE8C547).withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: const Color(0xFF8B6914),
                      size: 16.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ALL FEATURES DIALOG
  // ════════════════════════════════════════════════════════════════

  void _showAllFeaturesDialog(
    BuildContext context, {
    required NewUserSubModel? sub,
    required String planLabel,
    required num? price,
    required String currency,
  }) {
    final allFeatures = _buildAllFeatureItems(context, sub);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Dialog header ──
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 16.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBD8F14), Color(0xFFF5C003)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planLabel,
                              style: Styles.textStyle16SemiBold.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (price != null) ...[
                              Gap(2.h),
                              Text(
                                '${price.toStringAsFixed(0)} $currency',
                                style: Styles.textStyle12.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // X close button
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable features list ──
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                    child: Column(
                      children: allFeatures
                          .map(
                            (f) => Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: _buildFeatureRow(context, f),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FEATURE ROW
  // ════════════════════════════════════════════════════════════════

  Widget _buildFeatureRow(BuildContext context, Map<String, String> feature) {
    const goldGradient = [Color(0xFFBD8F14), Color(0xFFF5C003)];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: goldGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: SvgPicture.asset(
            AssetsData.checkPackageItems,
            width: 18.w,
            height: 18.h,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature['title']!,
                style: Styles.textStyle14SemiBold.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if ((feature['desc'] ?? '').isNotEmpty) ...[
                Text(
                  feature['desc']!,
                  style: Styles.textStyle12.copyWith(color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FEATURES DATA
  // First 5: dynamic from API (no boosts), Next 7: static premium perks
  // ════════════════════════════════════════════════════════════════

  List<Map<String, String>> _buildAllFeatureItems(
    BuildContext context,
    NewUserSubModel? sub,
  ) {
    final chatRooms = sub?.numberOfChatRooms ?? 0;
    final chatMins = sub?.numberOfChatRoomMins ?? 0;
    final greetings = sub?.numberOfDailyGreetings ?? 0;
    final renables = sub?.numberOfFreeMatchingRenables ?? 0;
    // numberOfFreeWeeklyReinforcements → skipped (no boosts)

    return [
      // — Dynamic features from API —
      {
        'title': context.tr('feature_unlimited_likes'),
        'desc': context.tr('feature_unlimited_likes_desc'),
      },
      {
        'title': context
            .tr('feature_chat_rooms')
            .replaceAll('{count}', '$chatRooms'),
        'desc': context.tr('feature_chat_rooms_desc'),
      },
      {
        'title': context
            .tr('feature_chat_mins')
            .replaceAll('{count}', '$chatMins'),
        'desc': context
            .tr('feature_chat_mins_desc')
            .replaceAll('{count}', '$chatMins'),
      },
      {
        'title': context
            .tr('feature_daily_greetings')
            .replaceAll('{count}', '$greetings'),
        'desc': context.tr('feature_daily_greetings_desc'),
      },
      {
        'title': context
            .tr('feature_matching_renables')
            .replaceAll('{count}', '$renables'),
        'desc': context.tr('feature_matching_renables_desc'),
      },
      // — Static premium perks —
      {
        'title': context.tr('feature_see_who_liked_you'),
        'desc': context.tr('feature_see_who_liked_you_desc'),
      },
      {
        'title': context.tr('feature_advanced_filters'),
        'desc': context.tr('feature_advanced_filters_desc'),
      },
      {
        'title': context.tr('feature_read_receipts'),
        'desc': context.tr('feature_read_receipts_desc'),
      },
      {
        'title': context.tr('feature_invisible_mode'),
        'desc': context.tr('feature_invisible_mode_desc'),
      },
      {
        'title': context.tr('feature_priority_search'),
        'desc': context.tr('feature_priority_search_desc'),
      },
      {
        'title': context.tr('feature_change_mind'),
        'desc': context.tr('feature_change_mind_desc'),
      },
      {
        'title': context.tr('feature_vip_badge'),
        'desc': context.tr('feature_vip_badge_desc'),
      },
    ];
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════

  String _getDurationLabel(BuildContext context, String? durationType) {
    switch (durationType?.toLowerCase()) {
      case 'weekly':
        return context.tr('weekly');
      case 'monthly':
        return context.tr('monthly');
      case 'threemonths':
        return context.tr('three_months');
      default:
        return context.tr('monthly');
    }
  }

  Widget _buildBenefitsSection(
    BuildContext context,
    PackageType selectedPackage,
  ) {
    final benefits = _getBenefitsForPackage(selectedPackage);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: benefits
            .map(
              (benefit) => _buildBenefitItem(
                context,
                icon: benefit['icon']!,
                title: benefit['title']!,
              ),
            )
            .toList(),
      ),
    );
  }

  List<Map<String, String>> _getBenefitsForPackage(PackageType packageType) {
    switch (packageType) {
      case PackageType.basic:
        return [
          {
            'icon': AssetsData.youNotSeeWhoLiked,
            'title': 'you_cannot_see_who_liked',
          },
          {
            'icon': AssetsData.limitedNumberOfLikes,
            'title': 'limited_number_of_likes',
          },
        ];
      case PackageType.pro:
        return [
          {
            'icon': AssetsData.youCanSeeWhoLiked,
            'title': 'you_can_see_who_liked',
          },
          {
            'icon': AssetsData.unlimitedNumberOfLikes,
            'title': 'unlimited_number_of_likes',
          },
        ];
      case PackageType.elite:
        return [];
    }
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required String icon,
    required String title,
  }) {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: 80.h, width: 80.w),
              Gap(8.h),
              Flexible(
                child: Text(
                  context.tr(title),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle14.copyWith(color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TAB SELECTOR
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabSelector() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) =>
          _buildCustomTabSelector(selectedPackage),
    );
  }

  Widget _buildCustomTabSelector(PackageType selectedPackage) {
    return Column(
      children: [
        SizedBox(
          height: 50.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sectionWidth = constraints.maxWidth / 2;
              const barColor = Color(0xFFD9D9D9);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 35.h,
                    left: 0,
                    right: 0,
                    child: Container(height: 5.h, color: barColor),
                  ),
                  Stack(
                    children: [
                      _buildTriangleAt(
                        isArabic ? sectionWidth * 0.48 : sectionWidth * 0.52,
                        barColor,
                      ),
                      _buildTriangleAt(
                        isArabic ? sectionWidth * 1.52 : sectionWidth * 1.48,
                        barColor,
                      ),
                    ],
                  ),
                  _buildSelectedIndicator(sectionWidth, selectedPackage),
                  Row(
                    children: [
                      _buildClickOverlay(PackageType.basic),
                      _buildClickOverlay(PackageType.pro),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        Gap(10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabText('Basic', PackageType.basic),
            _buildTabText('Pro', PackageType.pro),
          ],
        ),
      ],
    );
  }

  Widget _buildTriangleAt(double centerX, Color color) {
    return Positioned(
      left: centerX - 10.w,
      top: 35.h,
      child: CustomPaint(
        size: Size(20.w, 15.h),
        painter: _TrianglePainter(color: color),
      ),
    );
  }

  Widget _buildSelectedIndicator(
    double sectionWidth,
    PackageType selectedPackage,
  ) {
    final config = _getPackageConfig(selectedPackage);
    final visualIndex = isArabic ? (1 - config.index) : config.index;
    final centerX = sectionWidth * (visualIndex + 0.5);
    final scaleAnim = selectedPackage == PackageType.basic
        ? _basicScaleAnim
        : _proScaleAnim;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      left: centerX - 36.w,
      top: 0,
      child: ScaleTransition(
        scale: scaleAnim,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: config.colors,
                  begin: config.isVertical
                      ? Alignment.topCenter
                      : Alignment.centerRight,
                  end: config.isVertical
                      ? Alignment.bottomCenter
                      : Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: [
                  BoxShadow(
                    color: config.colors.last.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                context.tr(config.label),
                style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
              ),
            ),
            CustomPaint(
              size: Size(15.w, 10.h),
              painter: _TrianglePainter(
                colors: config.colors,
                isVertical: config.isVertical,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickOverlay(PackageType packageType) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<PackageSelectionCubit>().selectPackage(packageType),
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildTabText(String text, PackageType packageType) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<PackageSelectionCubit>().selectPackage(packageType),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            text,
            style: Styles.textStyle16.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }

  _PackageConfig _getPackageConfig(PackageType packageType) {
    switch (packageType) {
      case PackageType.basic:
        return _PackageConfig(
          index: 0,
          colors: [AppColors.primary300, AppColors.primary500],
          label: 'basic_package',
          isVertical: true,
        );
      case PackageType.pro:
        return _PackageConfig(
          index: 1,
          colors: const [Color(0xFFBD8F14), Color(0xFFF5C003)],
          label: 'gold_package',
          isVertical: false,
        );
      case PackageType.elite:
        return _PackageConfig(
          index: 2,
          colors: const [Color(0xFF4BB8F9), Color(0xFF6284FF)],
          label: 'elite_package',
          isVertical: true,
        );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ACTION BUTTON & OTHER WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget _buildActionButton() {
    return BlocBuilder<UserPackagesCubit, UserPackagesState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.subscriptions != curr.subscriptions,
      builder: (context, packagesState) {
        final isLoading = packagesState.isLoading;
        final currentPkg = context
            .read<UserPackagesCubit>()
            .currentSubscribedPackage;

        return BlocBuilder<PackageSelectionCubit, PackageSelectionState>(
          builder: (context, selectionState) {
            final selectedPackage = selectionState.selectedPackage;

            if (selectedPackage == PackageType.basic) {
              if (isLoading) return const SizedBox.shrink();
              if (currentPkg != null) return const SizedBox.shrink();
            }

            if (Platform.isAndroid &&
                !isLoading &&
                currentPkg != null &&
                selectedPackage != PackageType.basic) {
              return const SizedBox.shrink();
            }

            final isCurrentSub =
                selectedPackage != PackageType.basic &&
                currentPkg == selectedPackage;

            return UserPackageActionButton(
              packageType: selectedPackage,
              isCurrentSub: isCurrentSub,
              onPressed: () => _onActionButtonPressed(context, selectedPackage),
            );
          },
        );
      },
    );
  }

  Widget _buildKingIcon() {
    return Positioned(
      left: isArabic ? 65.w : null,
      right: !isArabic ? 25.w : null,
      top: 55.h,
      child: const PackageKingIcon(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // EVENT HANDLERS
  // ════════════════════════════════════════════════════════════════

  void _onPageChanged(int index) {
    const packages = [PackageType.basic, PackageType.pro];
    final pkg = packages[index];
    context.read<PackageSelectionCubit>().selectPackage(pkg);
    _triggerBalloonFor(pkg);
  }

  void _onPackageSelectionChanged(
    BuildContext context,
    PackageSelectionState state,
  ) {
    const packages = [PackageType.basic, PackageType.pro];
    final index = packages.indexOf(state.selectedPackage);

    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
    _triggerBalloonFor(state.selectedPackage);
  }

  void _onActionButtonPressed(BuildContext context, PackageType packageType) {
    if (packageType == PackageType.basic) {
      if (widget.fromPartnerFilter || widget.fromOnboarding) {
        if (widget.fromOnboarding) {
          kCurrentUserData = kCurrentUserData?.copyWith(compeletedData: true);
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.kUserLayoutView,
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
      return;
    }

    final currentPkg = context
        .read<UserPackagesCubit>()
        .currentSubscribedPackage;
    if (currentPkg != null) {
      _openSubscriptionManagement();
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.kUserSubscriptionView,
      arguments: _mapToOldEnum(packageType),
    );
  }

  Future<void> _openSubscriptionManagement() async {
    if (Platform.isIOS) {
      try {
        const channel = MethodChannel('com.athr.tayser/iap_manage');
        await channel.invokeMethod('showManageSubscriptions');
        return;
      } catch (_) {}
      final itmUri = Uri.parse(
        'itms-apps://apps.apple.com/account/subscriptions',
      );
      if (await canLaunchUrl(itmUri)) {
        await launchUrl(itmUri, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(
        Uri.parse('https://apps.apple.com/account/subscriptions'),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        Uri.parse('https://play.google.com/store/account/subscriptions'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  SelectedPackage _mapToOldEnum(PackageType packageType) {
    switch (packageType) {
      case PackageType.basic:
        return SelectedPackage.basic;
      case PackageType.pro:
        return SelectedPackage.pro;
      case PackageType.elite:
        return SelectedPackage.elite;
    }
  }
}

// ════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ════════════════════════════════════════════════════════════════

class _PackageConfig {
  final int index;
  final List<Color> colors;
  final String label;
  final bool isVertical;

  _PackageConfig({
    required this.index,
    required this.colors,
    required this.label,
    required this.isVertical,
  });
}

class _TrianglePainter extends CustomPainter {
  final List<Color>? colors;
  final Color? color;
  final bool isVertical;

  _TrianglePainter({this.colors, this.color, this.isVertical = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (colors != null) {
      paint.shader = LinearGradient(
        colors: colors!,
        begin: isVertical ? Alignment.topCenter : Alignment.centerRight,
        end: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else if (color != null) {
      paint.color = color!;
    }

    final path = Path();
    const radius = 2.0;
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(size.width / 2 + radius, size.height - radius);
    path.arcToPoint(
      Offset(size.width / 2 - radius, size.height - radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isVertical != isVertical ||
        oldDelegate.colors != colors;
  }
}
