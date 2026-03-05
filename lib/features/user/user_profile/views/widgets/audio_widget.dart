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

  List<double> _waveHeights = List.generate(40, (_) => 4.0);
  StreamSubscription? _recorderSubscription;

  Timer? _durationTimer;
  DateTime? _startTime;
  double _currentAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    try {
      // ✅ على iOS و Android: افتح الـ recorder الأول دايماً
      await _recorder!.openRecorder();

      await _recorder!.setSubscriptionDuration(
        const Duration(milliseconds: 150),
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Error initializing recorder: $e');
      // ✅ حتى لو في error، خلي الـ UI يظهر عشان المستخدم يحاول
      if (mounted) {
        setState(() => _isInitialized = true);
      }
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

  Future<bool> _requestPermission() async {
    // ✅ نفس المنطق على iOS و Android
    var status = await Permission.microphone.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('enable_microphone_settings')),

            action: SnackBarAction(
              label: context.tr('settings'),
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    // اطلب الـ permission
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _recorder == null) {
      // حاول تعمل initialize تاني
      await _initializeRecorder();
      if (!_isInitialized) return;
    }

    try {
      // ✅ اطلب الـ permission قبل التسجيل مباشرة
      final hasPermission = await _requestPermission();
      if (!hasPermission) return;

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
          SnackBar(
            content: Text('${context.tr('failed_to_start_recording')}: $e'),
          ),
        );
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isRecording || _isPaused) return;
      setState(() {
        _recordingDuration = DateTime.now().difference(_startTime!);
      });
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

        _currentAmplitude = (_currentAmplitude * 0.7) + (amplitude * 0.3);

        if (mounted) {
          setState(() => _addNewWave(_currentAmplitude));
        }
      },
      onError: (error) => debugPrint('❌ Recorder stream error: $error'),
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
      if (mounted) setState(() => _isPaused = true);
    } catch (e) {
      debugPrint('❌ Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (_recorder == null) return;
    try {
      await _recorder!.resumeRecorder();
      _startDurationTimer();
      if (mounted) setState(() => _isPaused = false);
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

      if (_recordingPath != null) {
        final audioFile = File(_recordingPath!);
        if (await audioFile.exists()) {
          widget.onAudioRecorded(audioFile);
        } else {
          debugPrint('❌ Audio file does not exist!');
        }
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (_recorder == null) return;
    try {
      if (_isRecording) {
        await _recorder!.stopRecorder();
      }
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
        if (await file.exists()) await file.delete();
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
    // ✅ لو لسه بيـ initialize، اظهر loading بسيط
    if (!_isInitialized) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(context.tr('initializing_recorder')),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: !_isRecording ? _buildIdleState() : _buildRecordingState(),
    );
  }

  // ── Idle: زرار الميكروفون فقط ──────────────────────────────────
  Widget _buildIdleState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 12.w),

          Text(
            context.tr('tap_to_record'),
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  // ── Recording state ────────────────────────────────────────────
  Widget _buildRecordingState() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: timer + dot + waves ──
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
                            color: (_isPaused ? Colors.orange : Colors.red)
                                .withOpacity(
                                  0.3 + (_animationController.value * 0.4),
                                ),
                            blurRadius: 4 + (_animationController.value * 4),
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
                      children: List.generate(_waveHeights.length, (index) {
                        final height = _waveHeights[index];
                        final color = Color.lerp(
                          AppColors.secondary200.withOpacity(0.5),
                          AppColors.secondary600,
                          (height / 35.0).clamp(0.0, 1.0),
                        )!;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          width: 2.5,
                          height: height,
                          margin: const EdgeInsets.symmetric(horizontal: 0.8),
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

            // ── Bottom row: cancel + pause + send ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ❌ حذف
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
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                // ⏸ / ▶ pause/resume
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

                // ✅ إرسال
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
                    child: Icon(Icons.send, color: Colors.white, size: 22.w),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
