import 'package:tayseer/features/advisor/profille/views/edit_certificate_view.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/video/video_player_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class ProfileCertificatesSection extends StatelessWidget {
  const ProfileCertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificatesCubit>(
      create: (_) => getIt<CertificatesCubit>(),
      child: const _CertificatesSectionContent(),
    );
  }
}

class _CertificatesSectionContent extends StatelessWidget {
  const _CertificatesSectionContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return _buildSkeletonSection();
          case CubitStates.failure:
            return _buildErrorSection(context, state.errorMessage);
          case CubitStates.success:
            return _buildContentSection(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          children: [
            // Video skeleton
            Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Gap(24.h),
            // Certificates skeleton
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 110.w,
                        height: 85.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120.w,
                              height: 20.h,
                              color: Colors.grey.shade400,
                            ),
                            Gap(8.h),
                            Container(
                              width: 100.w,
                              height: 16.h,
                              color: Colors.grey.shade400,
                            ),
                            Gap(8.h),
                            Container(
                              width: 60.w,
                              height: 16.h,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                      Gap(16.w),
                      Container(width: 20.w, height: 20.w, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            Gap(24.h),
            // Boost button skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.w),
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل الشهادات والفيديوهات',
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            onPressed: () => context.read<CertificatesCubit>().refresh(),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, CertificatesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Section
          if (state.hasVideo) _buildVideoSection(context, state.videoUrl!),

          Gap(24.h),
          Text(
            "الشهادات",
            style: Styles.textStyle18Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
          Gap(12.h),

          // Certificates List
          if (state.hasCertificates)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.certificates.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildCertificateItem(
                    context,
                    state.certificates[index],
                    state.isMe,
                  ),
                );
              },
            )
          else
            _buildNoCertificatesSection(),

          Gap(24.h),

          // Boost Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: BoostButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.kBoostAccountView);
              },
              text: 'تعزيز',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, String videoUrl) {
    return SizedBox(
      width: double.infinity,
      height: 400.h,
      child: VideoPlayerWidget(videoUrl: videoUrl, showFullScreenButton: true),
    );
  }

  Widget _buildCertificateItem(
    BuildContext context,
    CertificateModel certificate,
    bool isMe,
  ) {
    return GestureDetector(
      onTap: isMe
          ? () => _navigateToEditCertificate(context, certificate)
          : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary100),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Image
            SizedBox(
              width: 110.w,
              height: 85.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: certificate.image != null
                    ? CachedNetworkImage(
                        imageUrl: certificate.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.kprimaryColor,
                              strokeWidth: 2.w,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey.shade400,
                              size: 32.w,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.grey.shade400,
                            size: 32.w,
                          ),
                        ),
                      ),
              ),
            ),
            Gap(16.w),
            // Certificate Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.nameCertificate,
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.secondary800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  Text(
                    certificate.fromWhere,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  Text(
                    DateFormat('yyyy').format(certificate.date),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) ...[
              Gap(16.w),
              GestureDetector(
                onTap: () => _navigateToEditCertificate(context, certificate),
                child: AppImage(
                  AssetsData.editIcon,
                  width: 20.w,
                  color: AppColors.primary400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoCertificatesSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, color: Colors.grey.shade400, size: 48.w),
          Gap(16.h),
          Text(
            'لا توجد شهادات متاحة',
            style: Styles.textStyle16Meduim.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Gap(8.h),
          Text(
            'يمكنك إضافة شهاداتك من خلال تعديل البروفايل',
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToEditCertificate(
    BuildContext context,
    CertificateModel certificate,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRouter.kEditCertificateView),
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditCertificateView(certificate: certificate),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// class _VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const _VideoPlayerWidget({required this.videoUrl});

//   @override
//   State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   late VideoPlayerController _videoController;
//   late Future<void> _initializeVideoPlayerFuture;
//   bool _isPlaying = false;
//   bool _isMuted = false;
//   double _playbackSpeed = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     _videoController = VideoPlayerController.networkUrl(
//       Uri.parse(widget.videoUrl),
//     );
//     _initializeVideoPlayerFuture = _videoController.initialize();
//     _videoController.addListener(_videoListener);
//   }

//   void _videoListener() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _videoController.removeListener(_videoListener);
//     _videoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return _buildVideoPlayer();
//         } else {
//           return Container(
//             height: 400.h,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(16.r),
//             ),
//             child: Center(
//               child: CircularProgressIndicator(color: AppColors.kprimaryColor),
//             ),
//           );
//         }
//       },
//     );
//   }

//   Widget _buildVideoPlayer() {
//     final duration = _videoController.value.duration;
//     final position = _videoController.value.position;
//     final aspectRatio = _videoController.value.aspectRatio;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16.r),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Video Player
//             AspectRatio(
//               aspectRatio: aspectRatio > 0 ? aspectRatio : 16 / 9,
//               child: VideoPlayer(_videoController),
//             ),

//             // Play/Pause Overlay
//             if (!_isPlaying)
//               GestureDetector(
//                 onTap: _togglePlayPause,
//                 child: Container(
//                   width: 64.w,
//                   height: 64.w,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Icon(
//                       Icons.play_arrow,
//                       color: AppColors.kWhiteColor,
//                       size: 32.w,
//                     ),
//                   ),
//                 ),
//               ),

//             // Controls Overlay
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.8), Colors.transparent],
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     // Progress Bar
//                     Row(
//                       children: [
//                         Text(
//                           _formatDuration(position),
//                           style: Styles.textStyle12.copyWith(
//                             color: AppColors.kWhiteColor,
//                           ),
//                         ),
//                         Expanded(
//                           child: SliderTheme(
//                             data: SliderThemeData(
//                               trackHeight: 4.h,
//                               thumbShape: RoundSliderThumbShape(
//                                 enabledThumbRadius: 8.w,
//                               ),
//                               overlayShape: RoundSliderOverlayShape(
//                                 overlayRadius: 14.w,
//                               ),
//                             ),
//                             child: Slider(
//                               value: position.inSeconds.toDouble(),
//                               min: 0,
//                               max: duration.inSeconds.toDouble(),
//                               onChanged: (value) {
//                                 _videoController.seekTo(
//                                   Duration(seconds: value.toInt()),
//                                 );
//                               },
//                               activeColor: AppColors.kprimaryColor,
//                               inactiveColor: Colors.grey.shade400,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           _formatDuration(duration),
//                           style: Styles.textStyle12.copyWith(
//                             color: AppColors.kWhiteColor,
//                           ),
//                         ),
//                       ],
//                     ),

//                     // Controls
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Play/Pause
//                         IconButton(
//                           onPressed: _togglePlayPause,
//                           icon: Icon(
//                             _isPlaying
//                                 ? Icons.pause_circle_filled
//                                 : Icons.play_circle_filled,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                         ),

//                         // Mute/Unmute
//                         IconButton(
//                           onPressed: _toggleMute,
//                           icon: Icon(
//                             _isMuted ? Icons.volume_off : Icons.volume_up,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                         ),

//                         // Playback Speed
//                         PopupMenuButton<double>(
//                           icon: Icon(
//                             Icons.speed,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                           itemBuilder: (context) => [
//                             PopupMenuItem(value: 0.25, child: Text('0.25x')),
//                             PopupMenuItem(value: 0.5, child: Text('0.5x')),
//                             PopupMenuItem(value: 0.75, child: Text('0.75x')),
//                             PopupMenuItem(value: 1.0, child: Text('1x (عادي)')),
//                             PopupMenuItem(value: 1.25, child: Text('1.25x')),
//                             PopupMenuItem(value: 1.5, child: Text('1.5x')),
//                             PopupMenuItem(value: 2.0, child: Text('2x')),
//                           ],
//                           onSelected: (speed) {
//                             _videoController.setPlaybackSpeed(speed);
//                             _playbackSpeed = speed;
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('سرعة التشغيل: ${speed}x'),
//                                 duration: const Duration(seconds: 1),
//                               ),
//                             );
//                           },
//                         ),

//                         // Fullscreen
//                         IconButton(
//                           onPressed: _toggleFullScreen,
//                           icon: Icon(
//                             Icons.fullscreen,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                         ),

//                         // Skip Forward 10s
//                         IconButton(
//                           onPressed: _skipBackward,
//                           icon: Icon(
//                             Icons.forward_10,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                         ),
//                         // Skip Backward 10s
//                         IconButton(
//                           onPressed: _skipForward,
//                           icon: Icon(
//                             Icons.replay_10,
//                             color: AppColors.kWhiteColor,
//                             size: 24.w,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Current Speed Indicator
//             if (_playbackSpeed != 1.0)
//               Positioned(
//                 top: 12.h,
//                 left: 12.w,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Text(
//                     '${_playbackSpeed}x',
//                     style: Styles.textStyle12.copyWith(
//                       color: AppColors.kWhiteColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));

//     if (duration.inHours > 0) {
//       return '$hours:$minutes:$seconds';
//     }
//     return '$minutes:$seconds';
//   }

//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//       if (_isPlaying) {
//         _videoController.play();
//       } else {
//         _videoController.pause();
//       }
//     });
//   }

//   void _toggleMute() {
//     setState(() {
//       _isMuted = !_isMuted;
//       _videoController.setVolume(_isMuted ? 0.0 : 1.0);
//     });
//   }

//   void _skipBackward() {
//     final newPosition =
//         _videoController.value.position - const Duration(seconds: 10);
//     _videoController.seekTo(newPosition);
//   }

//   void _skipForward() {
//     final newPosition =
//         _videoController.value.position + const Duration(seconds: 10);
//     _videoController.seekTo(newPosition);
//   }

//   void _toggleFullScreen() {
//     // TODO: Implement full screen mode
//     // يمكن استخدام package مثل chewie أو video_player_controls
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('وضع الشاشة الكاملة قيد التطوير'),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }
// }
