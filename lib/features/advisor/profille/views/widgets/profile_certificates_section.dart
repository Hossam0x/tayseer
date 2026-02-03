import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/profille/views/add_certificate_view.dart';
import 'package:tayseer/features/advisor/profille/views/edit_certificate_view.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/video/video_player_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileCertificatesSection extends StatefulWidget {
  final String advisorId;
  final bool isMe;

  const ProfileCertificatesSection({
    super.key,
    required this.advisorId,
    required this.isMe,
  });

  @override
  State<ProfileCertificatesSection> createState() =>
      _ProfileCertificatesSectionState();
}

class _ProfileCertificatesSectionState extends State<ProfileCertificatesSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isMe = widget.isMe;

    // ⭐ استخدام الـ Cubit الموجود من الـ context
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      builder: (context, state) {
        if (state.state == CubitStates.loading && !state.hasLoadedOnce) {
          return _buildSkeletonSection();
        }

        if (state.state == CubitStates.failure && state.certificates.isEmpty) {
          return _buildErrorSection(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<CertificatesCubit>().refresh(
              advisorId: widget.advisorId,
            );
          },
          child: Column(
            children: [
              _buildContentSection(context, state, isMe),
              if (state.hasMore) _buildLoadMoreButton(context, state),
              Gap(20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, CertificatesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: state.isLoadingMore
          ? Center(
              child: CircularProgressIndicator(color: AppColors.kprimaryColor),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.read<CertificatesCubit>().loadMore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kWhiteColor,
                  foregroundColor: AppColors.kprimaryColor,
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  'تحميل المزيد من الشهادات',
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    CertificatesState state,
    bool isMe,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasVideo) _buildVideoSection(context, state.videoUrl!),
          Gap(24.h),
          if (isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "الشهادات",
                  style: Styles.textStyle18Bold.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _navigateToAddCertificate(context);
                  },
                  label: Text(
                    'إضافة',
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.secondary400,
                    ),
                  ),
                  icon: Icon(
                    Icons.add,
                    size: 22.w,
                    color: AppColors.secondary400,
                  ),
                ),
              ],
            ),
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
                    isMe,
                  ),
                );
              },
            )
          else
            _buildNoCertificatesSection(),
          Gap(24.h),
          if (isMe)
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

  // ... باقي الـ methods كما هي (نفس الكود السابق)
  Widget _buildSkeletonSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 400.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Gap(24.h),
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

  Widget _buildErrorSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            'حدث خطأ في تحميل الشهادات',
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
          ),
          Gap(24.h),
          ElevatedButton(
            onPressed: () => context.read<CertificatesCubit>().refresh(
              advisorId: widget.advisorId,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
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

  void _navigateToAddCertificate(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddCertificateView(),
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
    ).then((result) {
      if (result == true && context.mounted) {
        context.read<CertificatesCubit>().refresh(advisorId: widget.advisorId);
      }
    });
  }

  Widget _buildCertificateItem(
    BuildContext context,
    CertificateModel certificate,
    bool isMe,
  ) {
    if (certificate.nameCertificate.isEmpty) {
      return Container();
    }

    return GestureDetector(
      onTap: () =>
          isMe ? _navigateToEditCertificate(context, certificate) : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary100),
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.whiteCardBack,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 110.w,
              height: 90.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey.shade100,
              ),
              child: certificate.image != null && certificate.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        certificate.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.school,
                          color: Colors.grey.shade400,
                          size: 22.w,
                        ),
                      ),
                    )
                  : Icon(Icons.school, color: Colors.grey.shade400, size: 22.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.nameCertificate,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    certificate.fromWhere,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('yyyy').format(certificate.date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) AppImage(AssetsData.editIcon, width: 20.w),
          ],
        ),
      ),
    );
  }

  void _navigateToEditCertificate(
    BuildContext context,
    CertificateModel selectedCertificate,
  ) {
    final certificatesCubit = context.read<CertificatesCubit>();

    Navigator.push(
      context,
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRouter.kEditCertificateView),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: certificatesCubit,
            child: EditCertificateView(
              certificates: certificatesCubit.state.certificates,
              selectedCertificate: selectedCertificate,
            ),
          );
        },
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
    ).then((result) {
      if (result != null && result is Map && result['updated'] == true) {
        // ⭐ تحديث محلي فوري
        if (result['certificate'] != null) {
          certificatesCubit.updateCertificateLocally(result['certificate']);
        }
        // ⭐ تحديث من السيرفر للتأكد
        certificatesCubit.refresh(advisorId: widget.advisorId);
      }
    });
  }

  Widget _buildVideoSection(BuildContext context, String videoUrl) {
    return SizedBox(
      width: double.infinity,
      height: 400.h,
      child: VideoPlayerWidget(videoUrl: videoUrl, showFullScreenButton: true),
    );
  }

  Widget _buildNoCertificatesSection() {
    return Container(
      width: double.infinity,
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
        ],
      ),
    );
  }
}
