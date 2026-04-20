import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_location_cubit.dart';
import 'package:tayseer/features/user/marriage/view/widget/location_lock_widget.dart';
import 'package:tayseer/my_import.dart';

class MarriageLocationGuard extends StatefulWidget {
  final Widget child;

  const MarriageLocationGuard({super.key, required this.child});

  @override
  State<MarriageLocationGuard> createState() => _MarriageLocationGuardState();
}

class _MarriageLocationGuardState extends State<MarriageLocationGuard>
    with WidgetsBindingObserver {
  late final MarriageLocationCubit _locationCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize the cubit with the repository.
    // Using getIt since MarriageRepository is usually registered there.
    _locationCubit = MarriageLocationCubit(getIt<MarriageRepository>());
    _locationCubit.checkAndSetLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final currentState = _locationCubit.state;
      // Re-check automatically if the previous attempt failed due to permission or disabled services.
      if (currentState is! MarriageLocationSuccess &&
          currentState is! MarriageLocationLoading) {
        _locationCubit.checkAndSetLocation(requestPermission: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locationCubit,
      child: BlocBuilder<MarriageLocationCubit, MarriageLocationState>(
        builder: (context, state) {
          if (state is MarriageLocationLoading ||
              state is MarriageLocationInitial) {
            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
                  Container(color: Colors.white.withOpacity(0.55)),
                  Center(
                    child: Image.asset(
                      AssetsData.kGifOverlayLoading,
                      width: 400.w,
                      height: 400.w,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is MarriageLocationSuccess) {
            return widget.child;
          }

          if (state is MarriageLocationPermissionDenied) {
            return Scaffold(
              body: LocationLockWidget(
                message: context.tr('location_permission_title'),
                description:
                    context.tr(state.message) +
                    '\n' +
                    context.tr('location_permission_desc'),
                onTap: state.isForever
                    ? () => Geolocator.openAppSettings()
                    : () => _locationCubit.checkAndSetLocation(),
                titleBott: state.isForever
                    ? context.tr('location_settings_open')
                    : context.tr('location_grant_permission'),
              ),
            );
          }

          if (state is MarriageLocationServiceDisabled) {
            return Scaffold(
              body: LocationLockWidget(
                message: context.tr('location_service_disabled'),
                description: context.tr(state.message),
                onTap: () => Geolocator.openLocationSettings(),
                titleBott: context.tr('location_service_enable'),
              ),
            );
          }

          // Error state
          return Scaffold(
            body: LocationLockWidget(
              message: context.tr('location_error_occurred'),
              description: context.tr((state as MarriageLocationError).message),
              onTap: () => _locationCubit.checkAndSetLocation(),
              titleBott: context.tr('location_retry'),
            ),
          );
        },
      ),
    );
  }
}
