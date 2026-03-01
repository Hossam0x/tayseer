import 'dart:async';
import 'dart:math' as math;

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
  List<double> _waveHeights = List.generate(40, (_) => 4.0);
  StreamSubscription? _recorderSubscription;

  Timer? _durationTimer;
  DateTime? _startTime;

  // ✅ للأنيميشن السلس
  double _currentAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    try {
      // ✅ على iOS: اطلب الـ permission الأول قبل openRecorder
      if (Platform.isIOS) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          debugPrint('❌ Microphone permission denied on iOS');
          return; // مش نكمل
        }
      }

      await _recorder!.openRecorder();

      await _recorder!.setSubscriptionDuration(
        const Duration(milliseconds: 150),
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing recorder: $e');
    }
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

  // ✅ الحل: على iOS نتحقق فقط من الـ status ومش نطلب تاني
  // لأن الـ permission اتطلب من برا (في _startRecordingInPlace)
  Future<bool> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.status;

    // ✅ لو granted خلاص - مش محتاج نطلب تاني
    if (microphoneStatus == PermissionStatus.granted) {
      return true;
    }

    // ✅ لو permanentlyDenied - مش نطلب، نرجع false بس
    if (microphoneStatus == PermissionStatus.permanentlyDenied) {
      return false;
    }

    // ✅ iOS: مش نطلب من جوا الـ widget عشان متعارضش مع الطلب من برا
    if (Platform.isIOS) {
      // على iOS الـ permission اتطلب من _startRecordingInPlace
      // لو وصلنا هنا ومش granted، يبقى المستخدم رفض
      return false;
    }

    // Android: اطلب عادي
    final result = await Permission.microphone.request();
    return result == PermissionStatus.granted;
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _recorder == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recorder not initialized. Please try again.'),
          ),
        );
      }
      return;
    }

    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission is required to record audio',
              ),
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '${directory.path}/$fileName';

      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacMP4,
        bitRate: 128000,
        sampleRate: 44100,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
          _waveHeights = List.generate(40, (_) => 4.0);
          _currentAmplitude = 0.0;
          _startTime = DateTime.now();
        });
      }

      _startListeningToRecorder();
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

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isRecording || _isPaused) return;

      if (mounted) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  void _startListeningToRecorder() {
    _recorderSubscription?.cancel();

    _recorderSubscription = _recorder!.onProgress!.listen(
      (event) {
        if (!mounted || _isPaused) return;

        final decibels = event.decibels ?? -160.0;

        double amplitude;

        if (decibels <= -80) {
          amplitude = 0.01;
        } else {
          amplitude = ((decibels + 80) / 100).clamp(0.04, 0.4);
        }

        // ✅ تنعيم التغييرات (Smoothing)
        _currentAmplitude = (_currentAmplitude * 0.7) + (amplitude * 0.3);

        if (mounted) {
          setState(() {
            _addNewWave(_currentAmplitude);
          });
        }
      },
      onError: (error) {
        debugPrint('❌ Recorder stream error: $error');
      },
      cancelOnError: false,
    );
  }

  void _addNewWave(double amplitude) {
    final random = math.Random();
    final baseHeight = 5.0 + (amplitude * 30.0);

    _waveHeights.removeRange(0, 3);

    for (int i = 0; i < 3; i++) {
      final variation = 0.7 + (random.nextDouble() * 0.6);
      final height = (baseHeight * variation).clamp(4.0, 35.0);
      _waveHeights.add(height);
    }
  }

  Future<void> _pauseRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.pauseRecorder();
      _durationTimer?.cancel();
      if (mounted) {
        setState(() {
          _isPaused = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.resumeRecorder();
      _startDurationTimer();
      if (mounted) {
        setState(() {
          _isPaused = false;
        });
      }
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

      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
        });
      }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }

  Future<void> _cancelRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.stopRecorder();
      _recorderSubscription?.cancel();
      _durationTimer?.cancel();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _recordingDuration = Duration.zero;
          _waveHeights = List.generate(40, (_) => 4.0);
          _currentAmplitude = 0.0;
        });
      }

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
                    Row(
                      children: [
                        Text(
                          _formatDuration(_recordingDuration),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // النقطة النابضة
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _isPaused ? Colors.orange : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isPaused ? Colors.orange : Colors.red)
                                            .withOpacity(
                                              0.3 +
                                                  (_animationController.value *
                                                      0.4),
                                            ),
                                    blurRadius:
                                        4 + (_animationController.value * 4),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(width: 12.w),

                        // الموجات
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(_waveHeights.length, (
                                index,
                              ) {
                                final height = _waveHeights[index];

                                final color = Color.lerp(
                                  AppColors.secondary200.withOpacity(0.5),
                                  AppColors.secondary600,
                                  (height / 35.0).clamp(0.0, 1.0),
                                )!;

                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  width: 2.5,
                                  height: height,
                                  margin: EdgeInsets.symmetric(horizontal: 0.8),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: height > 20
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.3),
                                              blurRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
