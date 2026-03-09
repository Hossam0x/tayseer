import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/package_selection_cubit.dart';

class PackageKingIcon extends StatefulWidget {
  const PackageKingIcon({super.key});

  @override
  State<PackageKingIcon> createState() => _PackageKingIconState();
}

class _PackageKingIconState extends State<PackageKingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _rotateAnimation = Tween<double>(
      begin: -0.3,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        final isElite = packageType == PackageType.elite;

        if (isElite) {
          _controller.forward(from: 0.0);
        } else {
          _controller.reverse();
        }

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isElite ? 1.0 : 0.0,
          child: isElite
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: RepaintBoundary(
                          child: Transform.flip(
                            flipX: !isArabic,
                            child: SvgPicture.asset(
                              AssetsData.kingIcon,
                              height: 80.h,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
