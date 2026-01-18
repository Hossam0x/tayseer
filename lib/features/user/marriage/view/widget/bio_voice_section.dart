import 'package:audioplayers/audioplayers.dart';
import 'package:tayseer/my_import.dart';

class BioVoiceSection extends StatefulWidget {
  final String bioText;
  final String audioPath;

  const BioVoiceSection({
    super.key,
    required this.bioText,
    required this.audioPath,
  });

  @override
  State<BioVoiceSection> createState() => _BioVoiceSectionState();
}

class _BioVoiceSectionState extends State<BioVoiceSection> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isLocal = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _checkSourceType();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  void _checkSourceType() {
    if (widget.audioPath.startsWith('http')) {
      isLocal = false;
    } else {
      isLocal = true;
    }
  }

  Future<void> _toggleAudio() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (isLocal) {
          await _audioPlayer.play(DeviceFileSource(widget.audioPath));
        } else {
          await _audioPlayer.play(UrlSource(widget.audioPath));
        }
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  // دالة الانتقال لوقت معين عند اللمس
  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('my_cv'), style: Styles.textStyle16Bold),

            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: HexColor('#cccab3'),
                shape: BoxShape.circle,
              ),
              child: AppImage(
                AssetsData.kfavoriteIcon,
                width: 40.w,
                height: 40.h,
              ),
            ),
          ],
        ),
        Gap(12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF5F6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Text(
                widget.bioText,
                style: Styles.textStyle16.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: HexColor('#F2F3F5'),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleAudio,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFeb7a91),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    Gap(12.w),

                    // ✅ شكل الموجات التفاعلي
                    Expanded(
                      child: SizedBox(
                        height: 30.h,
                        child: _WaveformVisualizer(
                          duration: _duration,
                          position: _position,
                          onSeek: _seekTo, // نمرر دالة الـ Seek
                        ),
                      ),
                    ),

                    Gap(12.w),
                    // الوقت
                    Text(
                      _formatDuration(_position),
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(8.w),
                    Icon(
                      Icons.volume_up_rounded,
                      color: Colors.grey.shade700,
                      size: 20.sp,
                    ),
                    Gap(8.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaveformVisualizer extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final Function(Duration) onSeek;

  const _WaveformVisualizer({
    required this.duration,
    required this.position,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    const int barCount = 25;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _calculateSeek(
              details.localPosition.dx,
              constraints.maxWidth,
              isRtl,
            );
          },
          onHorizontalDragUpdate: (details) {
            _calculateSeek(
              details.localPosition.dx,
              constraints.maxWidth,
              isRtl,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(barCount, (index) {
              final double progress = duration.inMilliseconds == 0
                  ? 0
                  : position.inMilliseconds / duration.inMilliseconds;

              final int activeBars = (progress * barCount).round();
              final double randomHeight = _getBarHeight(index);

              final bool isActive = index < activeBars;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3.w,
                height: randomHeight.h,
                decoration: BoxDecoration(
                  // في حالة العربي، التلوين بيبدأ من اليمين، والـ Row بيعكسهم تلقائي
                  color: isActive
                      ? const Color(0xFF333333)
                      : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 2. تمرير متغير الاتجاه للدالة
  void _calculateSeek(double dx, double maxWidth, bool isRtl) {
    if (duration.inMilliseconds == 0) return;

    double percentage = dx / maxWidth;

    if (isRtl) {
      percentage = 1.0 - percentage;
    }

    percentage = percentage.clamp(0.0, 1.0);

    final newPosition = duration.inMilliseconds * percentage;
    onSeek(Duration(milliseconds: newPosition.round()));
  }

  double _getBarHeight(int index) {
    final List<double> pattern = [
      10,
      15,
      12,
      18,
      14,
      22,
      16,
      25,
      20,
      28,
      18,
      24,
      15,
      20,
      12,
      18,
      10,
      14,
      8,
      12,
      15,
      10,
      18,
      12,
      10,
    ];
    return pattern[index % pattern.length];
  }
}
