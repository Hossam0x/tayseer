import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/profille/views/edit_certificate_view.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/video/video_player_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الشهادات",
                style: Styles.textStyle18Bold.copyWith(
                  color: AppColors.secondary800,
                ),
              ),
              CustomBotton(
                title: 'اضافة شهادة',
                onPressed: () {},
                width: 120.w,
              ),
            ],
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
                    state.certificates, // ⭐ أضف هنا
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

  Widget _buildCertificateItem(
    BuildContext context,
    CertificateModel certificate,
    bool isMe,
    List<CertificateModel> allCertificates, // ⭐ أضف هنا
  ) {
    return Container(
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
          // if (isMe) ...[
          Gap(16.w),
          GestureDetector(
            onTap: () => _navigateToEditCertificate(context, allCertificates),
            child: AppImage(
              AssetsData.editIcon,
              width: 20.w,
              color: AppColors.primary400,
            ),
          ),
        ],
        // ],
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

  void _navigateToEditCertificate(
    BuildContext context,
    List<CertificateModel> certificates,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRouter.kEditCertificateView),
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditCertificateView(certificates: certificates),
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
        context.read<CertificatesCubit>().refresh();
      }
    });
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
}
