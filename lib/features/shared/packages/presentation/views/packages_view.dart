import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/domain/use_cases/get_package_display_data.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_action_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_background.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_detail_content.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_king_icon.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_tab_selector.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/restore_purchases_button.dart';

class PackagesView extends StatelessWidget {
  final int? initialPage;
  const PackagesView({super.key, this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<PackagesCubit>()..getPackages(),
        ),
        BlocProvider(create: (context) => PackageSelectionCubit()),
      ],
      child: _PackagesViewContent(initialPage: initialPage),
    );
  }
}

class _PackagesViewContent extends StatefulWidget {
  final int? initialPage;
  const _PackagesViewContent({this.initialPage});

  @override
  State<_PackagesViewContent> createState() => _PackagesViewContentState();
}

class _PackagesViewContentState extends State<_PackagesViewContent>
    with TickerProviderStateMixin {
  late PageController _pageController;
  final _getPackageData = GetPackageDisplayData();
  bool _initialPageSet = false;

  // Balloon scale animations
  late AnimationController _basicScaleController;
  late AnimationController _proScaleController;
  late AnimationController _eliteScaleController;
  late Animation<double> _basicScaleAnim;
  late Animation<double> _proScaleAnim;
  late Animation<double> _eliteScaleAnim;

  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFadeAnim;
  late Animation<Offset> _entranceSlideAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialPage ?? 0,
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
    _eliteScaleController = AnimationController(
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
    _eliteScaleAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _eliteScaleController,
            curve: Curves.easeInOut,
          ),
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
  }

  void _triggerBalloonFor(PackageType pkg) {
    if (pkg == PackageType.basic) {
      _basicScaleController.forward(from: 0);
    } else if (pkg == PackageType.pro) {
      _proScaleController.forward(from: 0);
    } else if (pkg == PackageType.elite) {
      _eliteScaleController.forward(from: 0);
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
    _eliteScaleController.dispose();
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
        BlocListener<PackagesCubit, PackagesState>(
          listenWhen: (prev, curr) =>
              prev.isLoading && !curr.isLoading && !_initialPageSet,
          listener: (context, state) {
            _initialPageSet = true;
            // If an explicit initialPage was passed, use it
            if (widget.initialPage != null) {
              const packages = [
                PackageType.basic,
                PackageType.pro,
                PackageType.elite,
              ];
              context.read<PackageSelectionCubit>().selectPackage(
                packages[widget.initialPage!],
              );
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  widget.initialPage!,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubic,
                );
              }
              return;
            }
            final cubit = context.read<PackagesCubit>();
            final currentPkg = cubit.currentSubscribedPackage;
            if (currentPkg != null) {
              const packages = [
                PackageType.basic,
                PackageType.pro,
                PackageType.elite,
              ];
              final index = packages.indexOf(currentPkg);
              context.read<PackageSelectionCubit>().selectPackage(currentPkg);
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubic,
                );
              }
            } else {
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
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          BlocSelector<
            PackageSelectionCubit,
            PackageSelectionState,
            PackageType
          >(
            selector: (state) => state.selectedPackage,
            builder: (context, selectedPackage) {
              final isElite = selectedPackage == PackageType.elite;
              return IconButton(
                icon: Transform.flip(
                  flipX: !isArabic,
                  child: SvgPicture.asset(
                    AssetsData.backArrow,
                    colorFilter: ColorFilter.mode(
                      isElite ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              );
            },
          ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: SafeArea(
        child: FadeTransition(
          opacity: _entranceFadeAnim,
          child: SlideTransition(
            position: _entranceSlideAnim,
            child: Column(
              children: [
                Expanded(child: _buildPageView()),
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
              ],
            ),
          ),
        ),
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
      itemCount: 3,
      itemBuilder: (context, index) {
        // Same order for all languages: Basic -> Pro -> Elite
        final packageTypes = [
          PackageType.basic,
          PackageType.pro,
          PackageType.elite,
        ];
        return _buildPage(packageTypes[index]);
      },
    );
  }

  Widget _buildPage(PackageType packageType) {
    return BlocBuilder<PackagesCubit, PackagesState>(
      buildWhen: (prev, curr) => prev.subscriptions != curr.subscriptions,
      builder: (context, state) {
        final packageData = _getPackageData(
          context: context,
          packageType: packageType,
          apiPackages: state.subscriptions,
        );
        return PackageDetailContent(
          package: packageData,
          packageType: packageType,
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return PackageTabSelector(
          selectedPackage: selectedPackage,
          onSelected: (pkg) =>
              context.read<PackageSelectionCubit>().selectPackage(pkg),
          basicScaleAnim: _basicScaleAnim,
          proScaleAnim: _proScaleAnim,
          eliteScaleAnim: _eliteScaleAnim,
        );
      },
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<PackagesCubit, PackagesState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.subscriptions != curr.subscriptions,
      builder: (context, packagesState) {
        final isLoading = packagesState.isLoading;
        final currentPkg = context
            .read<PackagesCubit>()
            .currentSubscribedPackage;

        return BlocBuilder<PackageSelectionCubit, PackageSelectionState>(
          builder: (context, selectionState) {
            final selectedPackage = selectionState.selectedPackage;

            // زرار "استمرار بحساب محدود" — مخفي لحد ما يتأكد من الـ subscription
            if (selectedPackage == PackageType.basic) {
              if (isLoading) return const SizedBox.shrink();
              if (currentPkg != null) return const SizedBox.shrink();
            }

            final isCurrentSub =
                selectedPackage != PackageType.basic &&
                currentPkg == selectedPackage;

            return PackageActionButton(
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
    // Same order for all languages: Basic (0) -> Pro (1) -> Elite (2)
    const packages = [PackageType.basic, PackageType.pro, PackageType.elite];
    final pkg = packages[index];
    context.read<PackageSelectionCubit>().selectPackage(pkg);
    _triggerBalloonFor(pkg);
  }

  void _onPackageSelectionChanged(
    BuildContext context,
    PackageSelectionState state,
  ) {
    // Same order for all languages: Basic (0) -> Pro (1) -> Elite (2)
    const packages = [PackageType.basic, PackageType.pro, PackageType.elite];
    final index = packages.indexOf(state.selectedPackage);
    final currentIndex = _pageController.page?.round() ?? 0;

    if (_pageController.hasClients && currentIndex != index) {
      // If skipping over a page (e.g. Basic → Elite), jump instantly to avoid
      // the eye-straining intermediate page flash
      if ((currentIndex - index).abs() > 1) {
        // Jump to adjacent page first (no animation), then animate the last step
        final intermediateIndex = index > currentIndex ? index - 1 : index + 1;
        _pageController.jumpToPage(intermediateIndex);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    }
    _triggerBalloonFor(state.selectedPackage);
  }

  void _onActionButtonPressed(BuildContext context, PackageType packageType) {
    if (packageType == PackageType.basic) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(
        context,
        AppRouter.kAdvisorSubscriptionView,
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
      case PackageType.elite:
        return SelectedPackage.elite;
    }
  }
}
