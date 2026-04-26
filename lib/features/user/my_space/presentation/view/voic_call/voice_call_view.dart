import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  });

  final String callID;
  final String userID;
  final String userName;
  final String avatarUrl;
  final List<Map<String, dynamic>> participants;

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
          BlocListener<CallCubit, CallState>(
            listenWhen: (previous, current) =>
                previous.sessionCancelledModel !=
                    current.sessionCancelledModel &&
                current.sessionCancelledModel != null,
            listener: (context, state) {
              _handleSessionEnd(
                context,
                state.sessionCancelledModel?.reason ?? "تم إلغاء الجلسة",
              );
            },
          ),
          // ✅ Listener للـ Session End
          BlocListener<CallCubit, CallState>(
            listenWhen: (previous, current) =>
                previous.isSessionEnd != current.isSessionEnd &&
                current.isSessionEnd == true,
            listener: (context, state) {
              _handleSessionEnd(context, state.sessionEndMessage);
            },
          ),
        ],
        child: _CallView(
          callID: callID,
          userID: userID,
          userName: userName,
          avatarUrl: avatarUrl,
          participants: participants,
        ),
      ),
    );
  }

  void _handleSessionEnd(BuildContext context, String message) async {
    // 1. اقفل المكالمة
    try {
      await ZegoUIKitPrebuiltCallController().hangUp(context);
    } catch (e) {
      debugPrint('Error hanging up: $e');
    }
    if (context.mounted) {
      AppToast.warning(context, message);
    }
    if (context.mounted) {
      context.read<CallCubit>().resetState();
    }
  }
}

class _CallView extends StatelessWidget {
  const _CallView({
    required this.callID,
    required this.userID,
    required this.userName,
    required this.avatarUrl,
    required this.participants,
  });

  final String callID;
  final String userID;
  final String userName;
  final String avatarUrl;
  final List<Map<String, dynamic>> participants;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1096376707,
      appSign:
          'bdd8e431ea191cfbf6b43e7842d78601aa8325f8e2259fd9ed85680a768dcef7',
      userID: userID,
      userName: userName,
      callID: callID,
      config: _buildCallConfig(context),
    );
  }

  ZegoUIKitPrebuiltCallConfig _buildCallConfig(BuildContext context) {
    final cubit = context.read<CallCubit>();
    final config = ZegoUIKitPrebuiltCallConfig.groupVoiceCall();

    config.background = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
    );

    config.audioVideoView.backgroundBuilder =
        (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
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
