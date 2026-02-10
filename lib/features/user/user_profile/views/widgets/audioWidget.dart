import 'dart:async';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tayseer/my_import.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(File audioFile) onAudioRecorded;
  final VoidCallback? onCancel;

  const VoiceRecordingWidget({
    super.key,
    required this.onAudioRecorded,
    this.onCancel,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  late AnimationController _animationController;
  String? _recordingPath;
  bool _isInitialized = false;
  
  // ⭐ للموجات الديناميكية
  List<double> _waveHeights = List.generate(40, (_) => 3.0);
  StreamSubscription? _recorderSubscription;
  
  // ✅ Timer بديل لضمان تحديث العداد
  Timer? _durationTimer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    
    // ✅ IMPORTANT: افتح الـ recorder مع logger
    await _recorder!.openRecorder();
    
    // ✅ تأكد من تفعيل setSubscriptionDuration
    await _recorder!.setSubscriptionDuration(
      const Duration(milliseconds: 100), // ✅ كل 100ms تحديث
    );
    
    setState(() {
      _isInitialized = true;
    });
    
    debugPrint('✅ Recorder initialized successfully');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorderSubscription?.cancel();
    _durationTimer?.cancel();
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus != PermissionStatus.granted) {
      final result = await Permission.microphone.request();
      return result == PermissionStatus.granted;
    }
    return true;
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _recorder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recorder not initialized. Please try again.'),
        ),
      );
      return;
    }

    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio'),
          ),
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '${directory.path}/$fileName';

      // ✅ ابدأ التسجيل
      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacMP4,
        bitRate: 128000,
        sampleRate: 44100,
      );

      debugPrint('✅ Recording started at: $_recordingPath');

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _waveHeights = List.generate(40, (_) => 3.0);
        _startTime = DateTime.now();
      });

      // ✅ ابدأ الاستماع للـ recorder
      _startListeningToRecorder();
      
      // ✅ ابدأ Timer احتياطي لضمان تحديث العداد
      _startDurationTimer();
      
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  // ✅✅✅ دالة جديدة: Timer احتياطي لضمان تحديث العداد
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isRecording || _isPaused) return;
      
      setState(() {
        _recordingDuration = DateTime.now().difference(_startTime!);
      });
    });
  }

  // ✅✅✅ الدالة المحدثة: استمع للـ onProgress
  void _startListeningToRecorder() {
    _recorderSubscription?.cancel();
    
    _recorderSubscription = _recorder!.onProgress!.listen(
      (event) {
        if (!mounted || _isPaused) return;

        debugPrint('📊 Progress event: duration=${event.duration}, decibels=${event.decibels}');

        // ✅ تحديث المدة من الـ event
        if (event.duration.inMilliseconds > 0) {
          _recordingDuration = event.duration;
        }

        // ✅ تحديث الموجات من الـ decibels
        final decibels = event.decibels ?? -160.0;
        
        // ✅ تحويل الـ decibels لارتفاع (من 3 إلى 30)
        // decibels عادة من -160 (صامت) إلى 0 (عالي جداً)
        double normalizedHeight;
        
        if (decibels < -100) {
          // صوت ضعيف جداً
          normalizedHeight = 3.0;
        } else if (decibels < -60) {
          // صوت متوسط
          normalizedHeight = ((decibels + 160) / 160 * 15).clamp(3.0, 15.0);
        } else {
          // صوت عالي
          normalizedHeight = ((decibels + 160) / 160 * 30).clamp(15.0, 30.0);
        }

        setState(() {
          // ✅ زحزح الموجات وأضف قيمة جديدة
          _waveHeights.removeAt(0);
          _waveHeights.add(normalizedHeight);
        });

        // ✅ أنيميشن خفيف
        _animationController.forward(from: 0.0);
      },
      onError: (error) {
        debugPrint('❌ Recorder stream error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> _pauseRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.pauseRecorder();
      _durationTimer?.cancel();
      setState(() {
        _isPaused = true;
      });
      debugPrint('⏸️ Recording paused');
    } catch (e) {
      debugPrint('❌ Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.resumeRecorder();
      _startDurationTimer();
      setState(() {
        _isPaused = false;
      });
      debugPrint('▶️ Recording resumed');
    } catch (e) {
      debugPrint('❌ Error resuming recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.stopRecorder();
      _recorderSubscription?.cancel();
      _durationTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      debugPrint('⏹️ Recording stopped');

      if (_recordingPath != null) {
        final audioFile = File(_recordingPath!);
        if (await audioFile.exists()) {
          debugPrint('✅ Audio file exists: $_recordingPath');
          widget.onAudioRecorded(audioFile);
        } else {
          debugPrint('❌ Audio file does not exist!');
        }
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.stopRecorder();
      _recorderSubscription?.cancel();
      _durationTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordingDuration = Duration.zero;
        _waveHeights = List.generate(40, (_) => 3.0);
      });

      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ Recording file deleted');
        }
      }

      widget.onCancel?.call();
    } catch (e) {
      debugPrint('❌ Error canceling recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Initializing recorder...'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (!_isRecording) ...[
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, color: Colors.white, size: 24),
              ),
            ),
          ] else ...[
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  children: [
                    // الصف الأول: الوقت + النقطة + الموجات
                    Row(
                      children: [
                        // الوقت
                        Text(
                          _formatDuration(_recordingDuration),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        
                        // النقطة الحمراء/البرتقالية
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isPaused ? Colors.orange : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isPaused ? Colors.orange : Colors.red)
                                    .withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // الموجات الديناميكية
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(40, (index) {
                                final height = _waveHeights[index];
                                
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeOut,
                                  width: 3,
                                  height: height,
                                  margin: EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.primary200.withOpacity(0.6),
                                        AppColors.primary200,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // الصف الثاني: الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الحذف
                        GestureDetector(
                          onTap: _cancelRecording,
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),

                        // زر Pause/Resume
                        GestureDetector(
                          onTap: _isPaused ? _resumeRecording : _pauseRecording,
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.orange[400],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),

                        // زر الإرسال
                        GestureDetector(
                          onTap: _stopRecording,
                          child: Container(
                            width: 45.w,
                            height: 45.h,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 22.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}