// ignore_for_file: unnecessary_null_comparison

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tayseer/my_import.dart';

class DownloadState {
  final bool isVisible;
  final double progress; // 0.0 to 1.0
  final String message;
  final bool isSuccess;
  final bool isError;

  DownloadState({
    this.isVisible = false,
    this.progress = 0.0,
    this.message = '',
    this.isSuccess = false,
    this.isError = false,
  });

  DownloadState copyWith({
    bool? isVisible,
    double? progress,
    String? message,
    bool? isSuccess,
    bool? isError,
  }) {
    return DownloadState(
      isVisible: isVisible ?? this.isVisible,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
    );
  }
}

/// سيرفس لتحميل الفيديوهات وحفظها في Gallery الجهاز.
/// Singleton يمكن استخدامه في أي مكان بالتطبيق.
class VideoDownloadService {
  static final VideoDownloadService _instance =
      VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  // Notifier لتحديث الـ UI الخاص بالـ Overlay
  final ValueNotifier<DownloadState> downloadStateNotifier = ValueNotifier(
    DownloadState(),
  );

  OverlayEntry? _overlayEntry;

  // Notification setup
  static const int _notificationId = 9999;
  static const String _channelId = 'video_download_channel';
  static const String _channelName = 'tayseer_video_download';
  static const String _channelDescription = 'tayseer_video_download_progress';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _notificationsInitialized = false;

  Future<void> _initNotifications() async {
    // على iOS الإشعارات بتتكرر ومش بتشتغل صح، فبنكتفي بالـ Overlay بس
    if (Platform.isIOS) return;
    if (_notificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@drawable/app_logo_icon',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _notificationsInitialized = true;
  }

  Future<void> _showProgressNotification(
    int progress,
    String notificationTitle,
  ) async {
    if (Platform.isIOS) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@drawable/app_logo_icon',
    );

    final details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      _notificationId,
      notificationTitle,
      '$progress%',
      details,
    );
  }

  Future<void> _cancelNotification() async {
    if (Platform.isIOS) return;
    await _notificationsPlugin.cancel(_notificationId);
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 20.h + MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          child: Material(
            color: Colors.transparent,
            child: ValueListenableBuilder<DownloadState>(
              valueListenable: downloadStateNotifier,
              builder: (context, state, child) {
                if (!state.isVisible) return const SizedBox.shrink();

                Color bgColor;
                IconData icon;
                Color iconColor;

                if (state.isSuccess) {
                  bgColor = AppColors.kgreen;
                  icon = Icons.check_circle_rounded;
                  iconColor = Colors.white;
                } else if (state.isError) {
                  bgColor = AppColors.kRedColor;
                  icon = Icons.error_rounded;
                  iconColor = Colors.white;
                } else {
                  bgColor = AppColors.secondary100;
                  icon = Icons.downloading_rounded;
                  iconColor = AppColors.kprimaryColor;
                }

                return AnimatedOpacity(
                  opacity: state.isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: iconColor, size: 24.sp),
                            Gap(12.w),
                            Expanded(
                              child: Text(
                                state.message,
                                style: Styles.textStyle14SemiBold.copyWith(
                                  color: (state.isSuccess || state.isError)
                                      ? Colors.white
                                      : AppColors.secondary800,
                                ),
                              ),
                            ),
                            if (!state.isSuccess && !state.isError)
                              Text(
                                '${(state.progress * 100).toInt()}%',
                                style: Styles.textStyle12SemiBold.copyWith(
                                  color: AppColors.kprimaryColor,
                                ),
                              ),
                          ],
                        ),
                        if (!state.isSuccess && !state.isError) ...[
                          Gap(10.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: state.progress,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.kprimaryColor,
                              ),
                              minHeight: 4.h,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _hideOverlayDelayed() async {
    await Future.delayed(const Duration(seconds: 3));
    downloadStateNotifier.value = downloadStateNotifier.value.copyWith(
      isVisible: false,
    );
    await Future.delayed(const Duration(milliseconds: 300));
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> downloadVideo({
    required BuildContext context,
    required String videoUrl,
  }) async {
    if (_isDownloading) {
      if (context.mounted) _showOverlay(context);
      downloadStateNotifier.value = downloadStateNotifier.value.copyWith(
        message: context.tr(AppStrings.downloadInProgress),
      );
      return;
    }

    if (videoUrl.isEmpty) {
      if (context.mounted) _showOverlay(context);
      downloadStateNotifier.value = DownloadState(
        isVisible: true,
        isError: true,
        message: context.tr(AppStrings.noVideoToDownload),
      );
      _hideOverlayDelayed();
      return;
    }

    // ✅ حفظ كل الترجمات مرة واحدة قبل بداية التحميل
    // عشان لو المستخدم عمل pop والـ context اتدمر، النصوص تفضل شغالة
    final trDownloadingVideo = context.tr(AppStrings.downloadingVideo);
    final trDownloading = context.tr(AppStrings.downloading);
    final trProcessing = context.tr(AppStrings.processing);
    final trVideoSaved = context.tr(AppStrings.videoSavedSuccess);
    final trFailedDownload = context.tr(AppStrings.failedDownloadFile);
    final trErrorDownloading = context.tr(AppStrings.errorDownloadingVideo);
    final trAllowGallery = context.tr(AppStrings.allowGallery);

    _isDownloading = true;

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        if (context.mounted) {
          _showOverlay(context);
          downloadStateNotifier.value = DownloadState(
            isVisible: true,
            isError: true,
            message: trAllowGallery,
          );
          _hideOverlayDelayed();
        }
        _isDownloading = false;
        return;
      }

      await _initNotifications();

      if (context.mounted) {
        _showOverlay(context);
      }
      downloadStateNotifier.value = DownloadState(
        isVisible: true,
        progress: 0.0,
        message: trDownloadingVideo,
      );
      await _showProgressNotification(0, trDownloadingVideo);

      final tempDir = await getTemporaryDirectory();
      final fileName = 'tayseer_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savePath = '${tempDir.path}/$fileName';

      final dio = getIt<Dio>();

      await dio.download(
        videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final currentProgress = received / total;
          final percent = (currentProgress * 100).toInt();

          _showProgressNotification(percent, trDownloadingVideo);

          downloadStateNotifier.value = downloadStateNotifier.value.copyWith(
            progress: currentProgress,
            message: trDownloading,
          );
        },
      );

      final file = File(savePath);
      if (!file.existsSync()) {
        throw Exception(trFailedDownload);
      }

      downloadStateNotifier.value = downloadStateNotifier.value.copyWith(
        message: trProcessing,
      );

      final asset = await PhotoManager.editor.saveVideo(file, title: fileName);

      // حذف الملف المؤقت
      if (file.existsSync()) {
        await file.delete();
      }

      await _cancelNotification();

      if (asset != null) {
        downloadStateNotifier.value = DownloadState(
          isVisible: true,
          isSuccess: true,
          message: trVideoSaved,
        );
      } else {
        downloadStateNotifier.value = DownloadState(
          isVisible: true,
          isError: true,
          message: trFailedDownload,
        );
      }
    } catch (e) {
      debugPrint('❌ Video download error: $e');
      await _cancelNotification();
      downloadStateNotifier.value = DownloadState(
        isVisible: true,
        isError: true,
        message: trErrorDownloading,
      );
    } finally {
      _isDownloading = false;
      _hideOverlayDelayed();
    }
  }
}
