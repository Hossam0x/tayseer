import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/domain/use_cases/get_package_display_data.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_action_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_background.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_detail_content.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_king_icon.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_tab_selector.dart';

class PackagesView extends StatelessWidget {
  const PackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<PackagesCubit>()..getPackages(),
        ),
        BlocProvider(create: (context) => PackageSelectionCubit()),
      ],
      child: const _PackagesViewContent(),
    );
  }
}

class _PackagesViewContent extends StatefulWidget {
  const _PackagesViewContent();

  @override
  State<_PackagesViewContent> createState() => _PackagesViewContentState();
}

class _PackagesViewContentState extends State<_PackagesViewContent> {
  late PageController _pageController;
  final _getPackageData = GetPackageDisplayData();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: isArabic ? 2 : 0);
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
        child: Column(
          children: [
            Expanded(child: _buildPageView()),
            _buildTabSelector(),
            Gap(110.h),
            _buildActionButton(),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const BouncingScrollPhysics(),
      reverse: !isArabic,
      children: isArabic
          ? [
              _buildPage(PackageType.elite),
              _buildPage(PackageType.pro),
              _buildPage(PackageType.basic),
            ]
          : [
              _buildPage(PackageType.basic),
              _buildPage(PackageType.pro),
              _buildPage(PackageType.elite),
            ],
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
        return PackageActionButton(
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
    final packages = isArabic
        ? [PackageType.elite, PackageType.pro, PackageType.basic]
        : [PackageType.basic, PackageType.pro, PackageType.elite];
    context.read<PackageSelectionCubit>().selectPackage(packages[index]);
  }

  void _onPackageSelectionChanged(
    BuildContext context,
    PackageSelectionState state,
  ) {
    final packages = isArabic
        ? [PackageType.elite, PackageType.pro, PackageType.basic]
        : [PackageType.basic, PackageType.pro, PackageType.elite];
    final index = packages.indexOf(state.selectedPackage);

    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
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
