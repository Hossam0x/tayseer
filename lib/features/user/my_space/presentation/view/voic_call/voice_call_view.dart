import 'dart:developer';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:tayseer/my_import.dart';

class CallPage extends StatefulWidget {
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
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  /// ✅ Map يربط كل userID بالصورة بتاعته
  final Map<String, String> _avatarsCache = {};

  @override
  void initState() {
    super.initState();
    _initializeAvatarsCache();
  }

  void _initializeAvatarsCache() {
    _avatarsCache[widget.userID] = widget.avatarUrl;
    log(
      '✅ Cached MY avatar: userID=${widget.userID}, avatar=${widget.avatarUrl}',
    );

    // 2️⃣ نخزن صور كل المشاركين (اليوزر التاني)
    for (var participant in widget.participants) {
      final String id = participant['id']?.toString() ?? '';
      final String avatarUrl = participant['avatarUrl']?.toString() ?? '';
      if (id.isNotEmpty) {
        _avatarsCache[id] = avatarUrl;
        log('✅ Cached PARTICIPANT avatar: id=$id, avatar=$avatarUrl');
      }
    }

    // 3️⃣ نطبع الكاش كامل للتأكد
    log('📦 Total avatars in cache: ${_avatarsCache.length}');
    _avatarsCache.forEach((id, avatar) {
      log('   👤 $id -> $avatar');
    });
  }

  @override
  void dispose() {
    log('📞 CallPage Dispose');
    ZegoUIKit().leaveRoom();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('📞 CallPage Build');
    log('   callID: ${widget.callID}');
    log('   My userID: ${widget.userID}');
    log('   My userName: ${widget.userName}');
    log('   Participants: ${widget.participants.length}');

    return ZegoUIKitPrebuiltCall(
      appID: 735715950,
      appSign:
          'c8c12ef18db02cdc1d880efdc0cbdde63f7362ff7068473ba7cb21240829ea6d',
      userID: widget.userID,
      userName: widget.userName,
      callID: widget.callID,
      config: _buildCallConfig(),
    );
  }

  ZegoUIKitPrebuiltCallConfig _buildCallConfig() {
    final config = ZegoUIKitPrebuiltCallConfig.groupVoiceCall();

    config.background = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
    );

    /// ✅ هنا نعرض صورة كل مستخدم داخل المكالمة
    config.audioVideoView.backgroundBuilder =
        (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
          if (user == null) return const SizedBox.shrink();

          final String? avatar = _avatarsCache[user.id];
          log(
            '🎨 Building avatar view for: ${user.id} (${user.name}) -> avatar: $avatar',
          );

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
                    child: ClipOval(child: _buildUserAvatar(avatar)),
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

    // ✅ إخفاء الأفاتار الافتراضي عند الصوت
    config.audioVideoView.showAvatarInAudioMode = false;

    // ✅ موجات الصوت
    config.audioVideoView.showSoundWavesInAudioMode = true;

    // ❌ إخفاء الشريط العلوي (زرار الأشخاص)
    config.topMenuBar.isVisible = false;
    config.topMenuBar.buttons = [];

    // ✅ إظهار كل الأزرار السفلية
    // ✅ إظهار كل الأزرار السفلية
    config.bottomMenuBar.buttons = [
      ZegoCallMenuBarButtonName.toggleMicrophoneButton, // 🎤 الميكروفون
      ZegoCallMenuBarButtonName.hangUpButton, // 📞 إنهاء المكالمة
      ZegoCallMenuBarButtonName.switchAudioOutputButton, // 🔊 الصوت
    ];

    return config;
  }

  /// ✅ بناء صورة المستخدم
  Widget _buildUserAvatar(String? avatar) {
    if (avatar != null && avatar.isNotEmpty) {
      return Image.network(
        avatar,
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
        errorBuilder: (context, error, stackTrace) {
          log('❌ Error loading avatar: $error');
          return const Icon(Icons.person, size: 40, color: Colors.white);
        },
      );
    }

    return const Icon(Icons.person, size: 40, color: Colors.white);
  }
}
