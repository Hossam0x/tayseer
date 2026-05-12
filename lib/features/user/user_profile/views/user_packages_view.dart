import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
  // ✅ تم إزالة _subscriptionSubscription — الـ UserPackagesCubit بيعمل refresh تلقائياً
  // عن طريق SubscriptionEventBus listener الداخلي، مش محتاجين listener تاني هنا

  // Animation controllers for balloon effect on tab buttons
  late AnimationController _basicScaleController;
  late AnimationController _proScaleController;
  late Animation<double> _basicScaleAnim;
  late Animation<double> _proScaleAnim;

  // Entrance animation for auto-scroll to Pro
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

    // Balloon scale animations
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

    // Entrance animation
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

    // ✅ لا نستمع للـ SubscriptionEventBus هنا — الـ UserPackagesCubit بيعمل ده تلقائياً
    // الـ double refresh كان بيحصل لأن الـ cubit بيعمل getPackages() من الـ event bus
    // والـ view كانت بتعمله تاني — ده كان يسبب 2 API calls متتاليين
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
              // Not subscribed → animate to Pro (gold) page
              Future.delayed(const Duration(milliseconds: 400), () {
                if (!mounted) return;
                // ✅ safe: mounted check is done before context.read
                final selectionCubit = context.read<PackageSelectionCubit>();
                selectionCubit.selectPackage(PackageType.pro);
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
                    Expanded(flex: 6, child: _buildPageView()),
                    const Spacer(),
                    _buildTabSelector(),
                    Gap(20.h),
                    _buildActionButton(),
                    Gap(12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: const AgreementText(),
                    ),
                    if (Platform.isIOS) ...[
                      Gap(4.h),
                      RestorePurchasesButton(
                        textColor: AppColors.kprimaryTextColor,
                      ),
                    ],
                    Gap(20.h),
                    _buildViewAllBenefitsButton(),
                    Gap(20.h),
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
      reverse: false,
      pageSnapping: true,
      itemCount: 2,
      itemBuilder: (context, index) {
        final packageTypes = [PackageType.basic, PackageType.pro];
        return _buildPage(packageTypes[index]);
      },
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    PackageType selectedPackage,
    UserPackagesState packagesState,
  ) {
    // ✅ لو Basic، اعرض الـ benefits القديمة
    if (selectedPackage == PackageType.basic) {
      return _buildBenefitsSection(context, selectedPackage);
    }

    // ✅ لو Pro، اعرض محتوى صفحة "كل المزايا" بدون جملة "استمتع بمزايا أكثر"
    final subs = packagesState.subscriptions
        .where((s) => s.subscriptionType == 'gold')
        .toList();
    final sub = subs.where((s) => s.isMonthly).firstOrNull ?? subs.firstOrNull;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: _buildFeaturesList(context, sub),
    );
  }

  Widget _buildFeaturesList(BuildContext context, NewUserSubModel? sub) {
    final features = _buildFeatures(context, sub);
    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
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
    const checkColors = [Color(0xFFBD8F14), Color(0xFFF5C003)];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
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
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description.isNotEmpty) ...[
                Gap(4.h),
                Text(
                  description,
                  style: Styles.textStyle12.copyWith(
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

  List<Map<String, String>> _buildFeatures(
    BuildContext context,
    NewUserSubModel? sub,
  ) {
    final likes = sub?.numberOfLikes ?? 0;
    final chatRooms = sub?.numberOfChatRooms ?? 0;
    final chatMins = sub?.numberOfChatRoomMins ?? 0;
    final greetings = sub?.numberOfDailyGreetings ?? 0;
    final reinforcements = sub?.numberOfFreeWeeklyReinforcements ?? 0;
    final renables = sub?.numberOfFreeMatchingRenables ?? 0;

    return [
      {
        'title': '$likes ${context.tr('unlimited_number_of_likes')}',
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
            'icon': AssetsData.thereAreNoFreeBoosts,
            'title': 'there_are_no_free_boosts',
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
            'icon': AssetsData.twoFreeCondolencesEveryWeek,
            'title': 'two_free_boosts_every_week',
          },
          {
            'icon': AssetsData.unlimitedNumberOfLikes,
            'title': 'unlimited_number_of_likes',
          },
        ];
      case PackageType.elite: // ✅ لن يتم الوصول إليه أبداً
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
        // ✅ لا يوجد elite بعد الآن، كل النصوص سوداء
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
              Gap(20.h),
              SizedBox(
                height: 80.h,
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

      case PackageType.elite: // ✅ لن يتم الوصول إليه أبداً
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabSelector() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        // ✅ Custom tab selector لـ Basic و Pro فقط
        return _buildCustomTabSelector(selectedPackage);
      },
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
                  // Horizontal line
                  Positioned(
                    top: 35.h,
                    left: 0,
                    right: 0,
                    child: Container(height: 5.h, color: barColor),
                  ),
                  // Static triangles
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
                  // Selected indicator with balloon scale
                  _buildSelectedIndicator(sectionWidth, selectedPackage),
                  // Clickable overlays
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
        // Tab labels with balloon scale
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
          label: "basic_package",
          isVertical: true,
        );
      case PackageType.pro:
        return _PackageConfig(
          index: 1,
          colors: const [Color(0xFFBD8F14), Color(0xFFF5C003)],
          label: "gold_package",
          isVertical: false,
        );
      case PackageType.elite:
        return _PackageConfig(
          index: 2,
          colors: const [Color(0xFF4BB8F9), Color(0xFF6284FF)],
          label: "elite_package",
          isVertical: true,
        );
    }
  }

  Widget _buildViewAllBenefitsButton() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        // ✅ اخفي الزر لأن المحتوى موجود بالفعل
        return const SizedBox.shrink();
      },
    );
  }

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

            // Hide basic button if user has an active subscription
            if (selectedPackage == PackageType.basic) {
              if (isLoading) return const SizedBox.shrink();
              if (currentPkg != null) return const SizedBox.shrink();
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.kUserLayoutView,
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pushNamed(
        context,
        AppRouter.kUserSubscriptionView,
        arguments: _mapToOldEnum(packageType),
      );
    }
  }

  SelectedPackage _mapToOldEnum(PackageType packageType) {
    switch (packageType) {
      case PackageType.basic:
        return SelectedPackage.basic;
      case PackageType.pro:
        return SelectedPackage.pro;
      case PackageType.elite: // ✅ لن يتم الوصول إليه أبداً
        return SelectedPackage.elite;
    }
  }
}

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
