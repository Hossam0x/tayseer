import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';

class PackageBackground extends StatefulWidget {
  const PackageBackground({super.key});

  @override
  State<PackageBackground> createState() => _PackageBackgroundState();
}

class _PackageBackgroundState extends State<PackageBackground> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Load all 3 backgrounds into the image cache immediately so the first
    // visible background appears without any blank-frame flash.
    precacheImage(const AssetImage(AssetsData.basicBackground), context);
    precacheImage(const AssetImage(AssetsData.proBackground), context);
    precacheImage(const AssetImage(AssetsData.eliteBackgroundPng), context);
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
        final index = PackageType.values.indexOf(packageType);
        return Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundLayer(
              assetPath: AssetsData.basicBackground,
              valueKey: const ValueKey('basic_bg'),
              visible: index == 0,
            ),
            _BackgroundLayer(
              assetPath: AssetsData.proBackground,
              valueKey: const ValueKey('pro_bg'),
              visible: index == 1,
            ),
            _BackgroundLayer(
              assetPath: AssetsData.eliteBackgroundPng,
              valueKey: const ValueKey('elite_bg'),
              visible: index == 2,
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  final String assetPath;
  final ValueKey<String> valueKey;
  final bool visible;

  const _BackgroundLayer({
    required this.assetPath,
    required this.valueKey,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: valueKey,
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: RepaintBoundary(
        child: AppImage(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
