import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';

class PackageBackground extends StatefulWidget {
  const PackageBackground({super.key});

  @override
  State<PackageBackground> createState() => _PackageBackgroundState();
}

class _PackageBackgroundState extends State<PackageBackground> {
  late final Widget _basicBg;
  late final Widget _proBg;
  late final Widget _eliteBg;

  @override
  void initState() {
    super.initState();
    _initializeBackgrounds();
  }

  void _initializeBackgrounds() {
    _basicBg = RepaintBoundary(
      child: SvgPicture.asset(
        AssetsData.basicBackground,
        key: const ValueKey('basic_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );

    _proBg = RepaintBoundary(
      child: SvgPicture.asset(
        AssetsData.proBackground,
        key: const ValueKey('pro_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );

    _eliteBg = RepaintBoundary(
      child: Image.asset(
        AssetsData.eliteBackgroundPng,
        key: const ValueKey('elite_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 1080.w.toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PackageSelectionCubit,
      PackageSelectionState,
      PackageType
    >(
      selector: (state) => state.selectedPackage,
      builder: (context, packageType) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _getBackground(packageType),
        );
      },
    );
  }

  Widget _getBackground(PackageType packageType) {
    switch (packageType) {
      case PackageType.basic:
        return _basicBg;
      case PackageType.pro:
        return _proBg;
      case PackageType.elite:
        return _eliteBg;
    }
  }
}
