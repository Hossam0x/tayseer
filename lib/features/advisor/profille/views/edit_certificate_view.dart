import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart'
    show CertificateModel;
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class EditCertificateView extends StatelessWidget {
  final List<CertificateModel> certificates;
  final CertificateModel? selectedCertificate;

  const EditCertificateView({
    super.key,
    required this.certificates,
    this.selectedCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final certificatesRepository = getIt<CertificatesRepository>();

    return BlocProvider(
      create: (context) => EditCertificateCubit(
        certificatesRepository,
        initialCertificate: selectedCertificate,
      ),
      child: Scaffold(
        body: BlocListener<EditCertificateCubit, EditCertificateState>(
          listenWhen: (previous, current) =>
              previous.isLoading != current.isLoading && !current.isLoading,
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.errorMessage!),
                isError: true,
              );
              context.read<EditCertificateCubit>().clearMessages();
            }

            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.successMessage!),
                isSuccess: true,
              );

              if (state.isNavigationSuccess) {
                // Try to update local list if CertificatesCubit is available
                try {
                  final certificatesCubit = context.read<CertificatesCubit>();
                  if (state.selectedCertificateId != null) {
                    final updatedCertificate = CertificateModel(
                      id: state.selectedCertificateId!,
                      nameCertificate: state.nameCertificate,
                      fromWhere: state.fromWhere,
                      date: state.date!,
                      image: state.certificateImageUrl,
                    );
                    certificatesCubit.updateCertificateLocally(
                      updatedCertificate,
                    );
                  }
                } catch (e) {
                  // ignore if not in context
                }

                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) Navigator.pop(context, true);
                });
              }
              context.read<EditCertificateCubit>().clearMessages();
            }
          },
          child: BlocBuilder<EditCertificateCubit, EditCertificateState>(
            builder: (context, state) {
              final cubit = context.read<EditCertificateCubit>();

              return AdvisorBackground(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 110.h,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                AssetsData.homeBarBackgroundImage,
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SimpleAppBar(
                                title: context.tr('edit_certificates'),
                                isLargeTitle: true,
                              ),
                              _buildImagePickerSection(context, cubit, state),
                              Gap(32.h),
                              ProfileTextField(
                                controller: state.nameCertificateController!,
                                onChanged: cubit.updateNameCertificate,
                                hint: context.tr('certificate_name_hint'),
                              ),
                              Gap(20.h),
                              ProfileTextField(
                                controller: state.fromWhereController!,
                                onChanged: cubit.updateFromWhere,
                                hint: context.tr('institution_name_hint'),
                              ),
                              Gap(20.h),
                              _buildDatePicker(context, cubit, state),
                              Gap(24.h),
                              CustomBotton(
                                height: 54.h,
                                width: context.width * 0.8,
                                useGradient: true,
                                title: state.isLoading
                                    ? context.tr('updating')
                                    : context.tr('update'),
                                onPressed: state.isLoading
                                    ? null
                                    : () => cubit.updateCertificate(),
                              ),
                              Gap(20.h),
                              if (certificates.isNotEmpty) ...[
                                SizedBox(
                                  height: 180.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    reverse: true,
                                    itemCount: certificates.length,
                                    itemBuilder: (context, index) {
                                      final cert = certificates[index];
                                      final isSelected =
                                          state.selectedCertificateId ==
                                          cert.id;

                                      return GestureDetector(
                                        onTap: () =>
                                            cubit.selectCertificate(cert),
                                        child: Container(
                                          width: 120.w,
                                          margin: EdgeInsets.only(left: 7.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.mainColor
                                                .withOpacity(0.1),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary300
                                                  : AppColors.mainColor,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 14.r,
                                                    right: 14.r,
                                                    top: 14.r,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16.r,
                                                        ),
                                                    child: Stack(
                                                      children: [
                                                        cert.image != null
                                                            ? CachedNetworkImage(
                                                                imageUrl:
                                                                    cert.image!,
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                placeholder:
                                                                    (
                                                                      context,
                                                                      url,
                                                                    ) =>
                                                                        _buildPlaceholder(),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) =>
                                                                        _buildErrorWidget(),
                                                              )
                                                            : _buildDefaultImage(),
                                                        Positioned(
                                                          top: 4.r,
                                                          left: 4.r,
                                                          child: AppImage(
                                                            AssetsData.editIcon,
                                                            width: 20.w,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              _buildCertDetails(cert),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Gap(20.h),
                              ],
                              Gap(20.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: Shimmer.fromColors(
        baseColor: AppColors.kprimaryColor,
        highlightColor: AppColors.kprimaryColor.withOpacity(0.5),
        child: Container(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.school, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildCertDetails(CertificateModel cert) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Text(
            cert.nameCertificate,
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            cert.fromWhere,
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            DateFormat('yyyy').format(cert.date),
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection(
    BuildContext context,
    EditCertificateCubit cubit,
    EditCertificateState state,
  ) {
    final hasLocalFile = state.certificateImageFile != null;
    final hasNetworkImage = state.certificateImageUrl != null;
    final hasAnyImage = hasLocalFile || hasNetworkImage;
    const heroTag = 'edit_certificate_image';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap(50.h),
        Stack(
          children: [
            GestureDetector(
              // Tap the image to open fullscreen viewer
              onTap: hasAnyImage
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageView(
                            imageFile:
                                hasLocalFile ? state.certificateImageFile : null,
                            imageUrl:
                                !hasLocalFile ? state.certificateImageUrl : null,
                            heroTag: heroTag,
                          ),
                        ),
                      )
                  : null,
              child: Container(
                height: 150.h,
                width: 155.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(32.r),
                  border:
                      Border.all(color: AppColors.primary100, width: 1.5),
                ),
                child: hasLocalFile
                    ? Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.file(
                            state.certificateImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      )
                    : hasNetworkImage
                    ? Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: AppImage(
                            state.certificateImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.school,
                          size: 40.w,
                          color: Colors.grey.shade500,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 10.r,
              right: 10.r,
              child: GestureDetector(
                onTap: cubit.pickCertificateImage,
                child: AppImage(AssetsData.addCertificateImage, width: 32.w),
              ),
            ),
            if (hasAnyImage)
              Positioned(
                top: 12.r,
                right: 12.r,
                child: GestureDetector(
                  onTap: cubit.removeCertificateImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kWhiteColor,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.kRedColor,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Gap(8.h),
        Text(
          context.tr('certificate_image_hint'),
          style:
              Styles.textStyle16.copyWith(color: AppColors.secondary400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    EditCertificateCubit cubit,
    EditCertificateState state,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.kprimaryColor,
                  onPrimary: Colors.white,
                  onSurface: AppColors.secondary800,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) cubit.updateDate(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Row(
          children: [
            AppImage(AssetsData.calenderIcon, width: 22.h),
            SizedBox(
              width: 30,
              height: 20,
              child: VerticalDivider(color: AppColors.primary100, thickness: 2),
            ),
            Expanded(
              child: Text(
                state.date != null
                    ? DateFormat('yyyy/MM/dd').format(state.date!)
                    : context.tr('choose_date'),
                style: Styles.textStyle14.copyWith(
                  color: state.date == null
                      ? AppColors.primary200
                      : AppColors.secondary800,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
