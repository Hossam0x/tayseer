import 'dart:async';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/view/voic_call/call_summary_page.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/call_cubit/call_cubit.dart';
import 'package:tayseer/my_import.dart';

class CallPage extends StatelessWidget {
  const CallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.avatarUrl,
    required this.participants,
    required this.advisorId,
    required this.advisorName,
    required this.advisorAvatarUrl,
    required this.isUserSide,
  });

  final String callID;
  final String userID;
  final String userName;
  final String avatarUrl;
  final List<Map<String, dynamic>> participants;

  /// معرف الـ advisor — لازم يتمرر عشان شاشة الملخص
  final String advisorId;
  final String advisorName;
  final String advisorAvatarUrl;

  /// true = المستخدم العادي (يشوف التقييم والإبلاغ)
  /// false = الـ advisor (ما يشوفش التقييم)
  final bool isUserSide;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CallCubit(getIt<MySpaceRepo>())
        ..fetchZegoCredentials()
        ..init(
          myUserId: userID,
          myAvatar: avatarUrl,
          participants: participants,
        )
        ..joinSession(callID)
        ..listenToSessionCallCancelled()
        ..listenToSessionEnd(),
      child: MultiBlocListener(
        listeners: [
          // انتهت مدة الجلسة فقط — sessionCancelled لا يقفل المكالمة
          BlocListener<CallCubit, CallState>(
            listenWhen: (previous, current) =>
                previous.isSessionEnd != current.isSessionEnd &&
                current.isSessionEnd == true,
            listener: (context, state) {
              _handleSessionExpired(context, state.sessionEndMessage);
            },
          ),
        ],
        child: _CallView(
          callID: callID,
          userID: userID,
          userName: userName,
          avatarUrl: avatarUrl,
          participants: participants,
          advisorId: advisorId,
          advisorName: advisorName,
          advisorAvatarUrl: advisorAvatarUrl,
          isUserSide: isUserSide,
        ),
      ),
    );
  }

  /// انتهت مدة الجلسة (sessionEnd) — نقفل المكالمة ونروح لشاشة الملخص
  void _handleSessionExpired(BuildContext context, String message) async {
    final cubit = context.read<CallCubit>();
    final durationSeconds = cubit.state.callDurationSeconds;

    try {
      await ZegoUIKitPrebuiltCallController().hangUp(context);
    } catch (e) {
      debugPrint('Error hanging up: $e');
    }

    if (context.mounted) {
      cubit.resetState();
      _navigateToSummary(context, message, durationSeconds);
    }
  }

  void _navigateToSummary(
    BuildContext context,
    String endReason,
    int durationSeconds,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CallSummaryPage(
          advisorId: advisorId,
          advisorName: advisorName,
          advisorAvatarUrl: advisorAvatarUrl,
          durationSeconds: durationSeconds,
          endReason: endReason,
          isUserSide: isUserSide,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CallView — الـ Zego widget مع تتبع مدة المكالمة
// ─────────────────────────────────────────────────────────────────────────────

class _CallView extends StatefulWidget {
  const _CallView({
    required this.callID,
    required this.userID,
    required this.userName,
    required this.avatarUrl,
    required this.participants,
    required this.advisorId,
    required this.advisorName,
    required this.advisorAvatarUrl,
    required this.isUserSide,
  });

  final String callID;
  final String userID;
  final String userName;
  final String avatarUrl;
  final List<Map<String, dynamic>> participants;
  final String advisorId;
  final String advisorName;
  final String advisorAvatarUrl;
  final bool isUserSide;

  @override
  State<_CallView> createState() => _CallViewState();
}

class _CallViewState extends State<_CallView> {
  Timer? _durationTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      if (mounted) {
        context.read<CallCubit>().updateCallDuration(_elapsedSeconds);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallCubit, CallState>(
      buildWhen: (previous, current) =>
          previous.zegoCredentialsState != current.zegoCredentialsState,
      builder: (context, state) {
        // Show loading while fetching credentials
        if (state.zegoCredentialsState == CubitStates.loading) {
          return _buildLoadingState();
        }

        // Show error if credentials fetch failed
        if (state.zegoCredentialsState == CubitStates.failure) {
          return _buildErrorState(
            context,
            state.zegoErrorMessage ?? 'فشل في تحميل بيانات المكالمة',
          );
        }

        // Show Zego call when credentials are loaded
        if (state.zegoCredentialsState == CubitStates.success &&
            state.zegoAppId != null &&
            state.zegoAppSign != null) {
          return ZegoUIKitPrebuiltCall(
            appID: state.zegoAppId!,
            appSign: state.zegoAppSign!,
            userID: widget.userID,
            userName: widget.userName,
            callID: widget.callID,
            config: _buildCallConfig(context),
            events: _buildCallEvents(context),
          );
        }

        // Fallback loading state
        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.kprimaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري تجهيز المكالمة...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 60),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<CallCubit>().fetchZegoCredentials();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kprimaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'العودة',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ZegoUIKitPrebuiltCallEvents _buildCallEvents(BuildContext context) {
    final cubit = context.read<CallCubit>();
    return ZegoUIKitPrebuiltCallEvents(
      onCallEnd: (event, defaultAction) {
        // remoteHangUp = الطرف الثاني خرج — نتجاهله ونخلي المكالمة مستمرة
        // المكالمة تتقفل بس لما المستخدم نفسه يضغط زر الإنهاء (localHangUp)
        // أو لما السيرفر يبعث sessionEnd
        if (event.reason == ZegoCallEndReason.remoteHangUp) {
          debugPrint('🔕 Remote user left — keeping call alive');
          return; // لا تعمل defaultAction ولا تروح للـ summary
        }

        // localHangUp أو kickOut أو abandoned → روح للـ summary
        final durationSeconds = cubit.state.callDurationSeconds;
        cubit.resetState();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CallSummaryPage(
                advisorId: widget.advisorId,
                advisorName: widget.advisorName,
                advisorAvatarUrl: widget.advisorAvatarUrl,
                durationSeconds: durationSeconds,
                endReason: '',
                isUserSide: widget.isUserSide,
              ),
            ),
          );
        }
      },
    );
  }

  ZegoUIKitPrebuiltCallConfig _buildCallConfig(BuildContext context) {
    final cubit = context.read<CallCubit>();
    final config = ZegoUIKitPrebuiltCallConfig.groupVoiceCall();

    // ─── Background ───────────────────────────────────────────
    config.background = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
    );

    // ─── Avatar builder ───────────────────────────────────────
    config.audioVideoView.backgroundBuilder =
        (BuildContext ctx, Size size, ZegoUIKitUser? user, Map extraInfo) {
          if (user == null) return const SizedBox.shrink();
          final avatar = cubit.getAvatar(user.id);
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsData.homeBackgroundImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kprimaryColor.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.kprimaryColor,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(child: _UserAvatar(avatar: avatar)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        };

    config.audioVideoView.showAvatarInAudioMode = false;
    config.audioVideoView.showSoundWavesInAudioMode = true;

    config.topMenuBar.isVisible = false;
    config.topMenuBar.buttons = [];

    config.bottomMenuBar.buttons = [
      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
      ZegoCallMenuBarButtonName.hangUpButton,
      ZegoCallMenuBarButtonName.switchAudioOutputButton,
    ];

    return config;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UserAvatar
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({this.avatar});

  final String? avatar;

  @override
  Widget build(BuildContext context) {
    if (avatar != null && avatar!.isNotEmpty) {
      return Image.network(
        avatar!,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.kprimaryColor,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.person, size: 40, color: Colors.white);
        },
      );
    }
    return const Icon(Icons.person, size: 40, color: Colors.white);
  }
}
