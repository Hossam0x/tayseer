import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tayseer/core/utils/colors.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File audioFile, Duration duration) onSendVoice;
  final VoidCallback onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onSendVoice,
    required this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  String? _audioPath;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // طلب الإذن
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        widget.onCancel();
        return;
      }

      // إنشاء مسار الملف
      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // بدء التسجيل
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      // بدء العداد
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration = Duration(seconds: timer.tick);
        });
      });
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      widget.onCancel();
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      await _audioRecorder.stop();

      if (_audioPath != null && File(_audioPath!).existsSync()) {
        final audioFile = File(_audioPath!);
        widget.onSendVoice(audioFile, _recordDuration);
      } else {
        widget.onCancel();
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      widget.onCancel();
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _timer?.cancel();
      await _audioRecorder.stop();

      // حذف الملف
      if (_audioPath != null && File(_audioPath!).existsSync()) {
        await File(_audioPath!).delete();
      }

      widget.onCancel();
    } catch (e) {
      debugPrint('❌ Error canceling recording: $e');
      widget.onCancel();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الإلغاء
          IconButton(
            onPressed: _cancelRecording,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // أيقونة الميكروفون المتحركة
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.kprimaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: AppColors.kprimaryColor,
                size: 24.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // مدة التسجيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'جاري التسجيل...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // زر الإرسال
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.kprimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
