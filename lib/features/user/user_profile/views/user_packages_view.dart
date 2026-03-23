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
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/domain/use_cases/get_package_display_data.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_background.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_king_icon.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_tab_selector.dart';
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_package_action_button.dart';

class UserPackagesView extends StatelessWidget {
  const UserPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<PackagesCubit>()..getPackages(),
        ),
        BlocProvider(create: (context) => PackageSelectionCubit()),
      ],
      child: const _UserPackagesViewContent(),
    );
  }
}

class _UserPackagesViewContent extends StatefulWidget {
  const _UserPackagesViewContent();

  @override
  State<_UserPackagesViewContent> createState() =>
      _UserPackagesViewContentState();
}

class _UserPackagesViewContentState extends State<_UserPackagesViewContent> {
  late PageController _pageController;
  final _getPackageData = GetPackageDisplayData();

  @override
  void initState() {
    super.initState();
    // Always start with Basic package (index 0)
    // Use viewportFraction: 1.0 and keepPage: true for better performance
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AssetsData.eliteBackgroundPng), context);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        child:
            BlocSelector<
              PackageSelectionCubit,
              PackageSelectionState,
              PackageType
            >(
              selector: (state) => state.selectedPackage,
              builder: (context, selectedPackage) {
                final isBasic = selectedPackage == PackageType.basic;

                return Column(
                  children: [
                    Expanded(child: _buildPageView()),
                    const Spacer(),
                    _buildTabSelector(),
                    if (isBasic) Gap(65.h) else Gap(10.h),
                    _buildActionButton(),
                    Gap(20.h),
                    _buildViewAllBenefitsButton(),
                    Gap(20.h),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildPageView() {
    return BlocBuilder<PackageSelectionCubit, PackageSelectionState>(
      builder: (context, state) {
        return Column(
          children: [
            Gap(20.h),
            Expanded(
              flex: 1,
              child: PageView.builder(
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
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildBenefitsSection(context, state.selectedPackage),
            ),
            Gap(40.h),
          ],
        );
      },
    );
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
      case PackageType.elite:
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
        final isElite = selectedPackage == PackageType.elite;

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
                  style: Styles.textStyle14.copyWith(
                    color: isElite ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage(PackageType packageType) {
    return BlocBuilder<PackagesCubit, PackagesState>(
      buildWhen: (prev, curr) => prev.packages != curr.packages,
      builder: (context, state) {
        final packageData = _getPackageData(
          context: context,
          packageType: packageType,
          apiPackages: state.packages,
        );
        // Show only the title without the feature grid
        return _buildSimplePackageContent(packageData, packageType);
      },
    );
  }

  Widget _buildSimplePackageContent(
    PackageDisplayModel package,
    PackageType packageType,
  ) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [_buildPackageTitle(package, packageType), Gap(40.h)],
        ),
      ),
    );
  }

  Widget _buildPackageTitle(
    PackageDisplayModel package,
    PackageType packageType,
  ) {
    switch (packageType) {
      case PackageType.elite:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                package.packageTitle,
                textAlign: TextAlign.center,
                style: Styles.textStyle24Meduim.copyWith(color: Colors.white),
              ),
            ),
          ],
        );

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
        return PackageTabSelector(
          selectedPackage: selectedPackage,
          onSelected: (pkg) =>
              context.read<PackageSelectionCubit>().selectPackage(pkg),
        );
      },
    );
  }

  Widget _buildViewAllBenefitsButton() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        // Only show for Pro and Elite packages
        if (selectedPackage == PackageType.basic) {
          return const SizedBox.shrink();
        }

        const gradientColors = [Color(0xFFBD8F14), Color(0xFFF5C003)];

        return Center(
          child: Container(
            width: 360.w,
            height: 55.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.r),
              gradient: const LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.5.r),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.6),
                  shadowColor: Colors.transparent.withOpacity(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.5.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.kUserPackageDetailsView,
                    arguments: selectedPackage,
                  );
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    context.tr('view_all_benefits'),
                    style: Styles.textStyle18SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return UserPackageActionButton(
          packageType: selectedPackage,
          onPressed: () => _onActionButtonPressed(context, selectedPackage),
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
    context.read<PackageSelectionCubit>().selectPackage(packages[index]);
  }

  void _onPackageSelectionChanged(
    BuildContext context,
    PackageSelectionState state,
  ) {
    // Same order for all languages: Basic (0) -> Pro (1) -> Elite (2)
    const packages = [PackageType.basic, PackageType.pro, PackageType.elite];
    final index = packages.indexOf(state.selectedPackage);

    if (_pageController.hasClients && _pageController.page?.round() != index) {
      // Use jumpToPage for instant transition without animation
      // This prevents the eye strain from seeing intermediate pages
      _pageController.jumpToPage(index);
    }
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
