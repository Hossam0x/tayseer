import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/features/user/marriage/view/widget/location_lock_widget.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_location_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/wallet_view.dart';
import 'package:tayseer/my_import.dart';

/// Guard that requests notification permission then checks location
/// before allowing access to [WalletView].
class WalletGuardView extends StatefulWidget {
  const WalletGuardView({super.key});

  @override
  State<WalletGuardView> createState() => _WalletGuardViewState();
}

class _WalletGuardViewState extends State<WalletGuardView>
    with WidgetsBindingObserver {
  late final MarriageLocationCubit _locationCubit;
  bool _notificationRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationCubit = MarriageLocationCubit(getIt<MarriageRepository>());
    _requestNotificationThenLocation();
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
      final current = _locationCubit.state;
      if (current is! MarriageLocationSuccess &&
          current is! MarriageLocationLoading) {
        _locationCubit.checkAndSetLocation(requestPermission: false);
      }
    }
  }

  Future<void> _requestNotificationThenLocation() async {
    if (!_notificationRequested) {
      _notificationRequested = true;
      try {
        final messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } catch (_) {
        // Notification permission failure should not block wallet access
      }
    }
    await _locationCubit.checkAndSetLocation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locationCubit,
      child: BlocBuilder<MarriageLocationCubit, MarriageLocationState>(
        builder: (context, state) {
          if (state is MarriageLocationLoading ||
              state is MarriageLocationInitial) {
            return const Scaffold(body: Center(child: CustomloadingApp()));
          }

          if (state is MarriageLocationSuccess) {
            return const WalletView();
          }

          if (state is MarriageLocationPermissionDenied) {
            return Scaffold(
              body: LocationLockWidget(
                message: context.tr('location_permission_title'),
                description:
                    '${context.tr(state.message)}\n${context.tr('location_permission_desc')}',
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
