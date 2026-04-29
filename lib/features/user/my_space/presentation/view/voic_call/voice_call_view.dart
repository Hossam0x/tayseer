import 'dart:async';
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
      create: (_) => CallCubit()
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
    return ZegoUIKitPrebuiltCall(
      appID: 1096376707,
      appSign:
          'bdd8e431ea191cfbf6b43e7842d78601aa8325f8e2259fd9ed85680a768dcef7',
      userID: widget.userID,
      userName: widget.userName,
      callID: widget.callID,
      config: _buildCallConfig(context),
      events: _buildCallEvents(context),
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
