import 'dart:async';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/my_import.dart';

/// بانر أوفلاين — يظهر/يختفي بأنميشن ناعمة
/// لما النت يرجع → يتحول لونه أخضر لمدة ثانية ونص ثم يختفي
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

enum _BannerMode { hidden, offline, restored }

class _OfflineBannerState extends State<OfflineBanner> {
  _BannerMode _mode = _BannerMode.hidden;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (prev, curr) => prev.isConnected != curr.isConnected,
      listener: (context, state) {
        _hideTimer?.cancel();

        if (!state.isConnected) {
          // النت فصل → بانر أوفلاين فوراً
          setState(() => _mode = _BannerMode.offline);
        } else {
          // النت رجع → بانر أخضر لمدة 1.5 ثانية ثم اختفاء
          if (_mode == _BannerMode.offline) {
            setState(() => _mode = _BannerMode.restored);
            _hideTimer = Timer(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() => _mode = _BannerMode.hidden);
            });
          }
        }
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _mode == _BannerMode.hidden
            ? const SizedBox.shrink()
            : _BannerContent(mode: _mode),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.mode});

  final _BannerMode mode;

  bool get _isRestored => mode == _BannerMode.restored;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: _isRestored ? const Color(0xFF2E7D32) : Colors.grey.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRestored ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              size: 14.sp,
              color: Colors.white70,
            ),
            SizedBox(width: 6.w),
            Text(
              _isRestored
                  ? context.tr(AppStrings.connectionRestored)
                  : context.tr(AppStrings.offlineNoConnection),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
