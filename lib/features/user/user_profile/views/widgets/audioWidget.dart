
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
// Import your existing message model and services
// import 'your_message_model.dart';
// import 'your_supabase_service.dart';

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
  late Animation<double> _scaleAnimation;
  String? _recordingPath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          'voice_message_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _recordingPath = '${directory.path}/$fileName';

      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacMP4, // ✅ هذا الترميز يفضل امتداد .mp4 أو .m4a
        bitRate: 128000,
        sampleRate: 44100,
      );
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _startTimer();
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start recording: $e')));
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!_isRecording || _isPaused) return false;

      await Future.delayed(const Duration(seconds: 1));

      if (mounted && _isRecording && !_isPaused) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _pauseRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.pauseRecorder();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.resumeRecorder();
      setState(() {
        _isPaused = false;
      });
      _startTimer();
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      if (_recordingPath != null) {
        final audioFile = File(_recordingPath!);
        if (await audioFile.exists()) {
          widget.onAudioRecorded(audioFile);
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
    }
  }

  Future<void> _cancelRecording() async {
    if (_recorder == null) return;

    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordingDuration = Duration.zero;
      });

      // Delete the recorded file
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      widget.onCancel?.call();
    } catch (e) {
      print('Error canceling recording: $e');
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Row(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (!_isRecording) ...[
            // Record button
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
          ] else ...[
            // Recording controls
            Expanded(
              child: Row(
                children: [
                  // Cancel button
                  GestureDetector(
                    onTap: _cancelRecording,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Pause/Resume button
                  GestureDetector(
                    onTap: _isPaused ? _resumeRecording : _pauseRecording,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Recording indicator with animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPaused ? 1.0 : _scaleAnimation.value,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isPaused ? Colors.orange : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Duration
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // Recording bars animation
                  Row(
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            width: 3,
                            height: 8 + (index * 4) * _scaleAnimation.value,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Send button
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
