import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:tayseer/core/enum/cubit_states.dart';

class AddCertificateView extends StatelessWidget {
  const AddCertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    final certificatesRepository = getIt<CertificatesRepository>();

    return BlocProvider(
      create: (context) => AddCertificateCubit(certificatesRepository),
      child: Scaffold(
        body: BlocListener<AddCertificateCubit, AddCertificateState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              showSafeSnackBar(
                context: context,
                text: state.errorMessage!,
                isError: true,
              );
              context.read<AddCertificateCubit>().clearMessage();
            } else if (state.successMessage != null &&
                state.state == CubitStates.success) {
              showSafeSnackBar(
                context: context,
                text: state.successMessage!,
                isSuccess: true,
              );
              context.read<AddCertificateCubit>().clearMessage();
              Navigator.pop(context, true);
            }
          },
          child: BlocBuilder<AddCertificateCubit, AddCertificateState>(
            builder: (context, state) {
              final cubit = context.read<AddCertificateCubit>();

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
                                title: context.tr('add_certificate'),
                              ),
                              // Certificate Image / Preview
                              _buildImagePickerSection(cubit, state, context),
                              Gap(32.h),
                              // Name Certificate field
                              ProfileTextField(
                                controller: state.nameCertificateController!,
                                onChanged: cubit.updateNameCertificate,
                                hint: context.tr('certificate_name_hint'),
                              ),

                              Gap(20.h),

                              ProfileTextField(
                                controller: state.fromWhereController!,
                                onChanged: cubit.updateFromWhere,
                                hint: context.tr('certificate_from_where_hint'),
                              ),
                              Gap(20.h),
                              // Date picker
                              _buildDatePicker(context, cubit, state),
                              Gap(24.h),
                              // Add Button
                              CustomBotton(
                                height: 54.h,
                                width: context.width * 0.8,
                                title: state.isLoading
                                    ? context.tr('adding_certificate')
                                    : context.tr('add'),
                                useGradient: true,
                                onPressed: state.isLoading
                                    ? null
                                    : () => cubit.addCertificate(),
                              ),
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

  Widget _buildImagePickerSection(
    AddCertificateCubit cubit,
    AddCertificateState state,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap(50.h),
        Stack(
          children: [
            GestureDetector(
              onTap: cubit.pickCertificateImage,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: state.certificateImageFile != null ? 0 : 45.r,
                ),
                height: 190.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.kWhiteColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.primary100),
                ),
                child: state.certificateImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.file(
                          state.certificateImageFile!,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppImage(AssetsData.uplaodCertificate, width: 35.w),
                            Gap(8.h),
                            Text(
                              context.tr('upload_image_or_pdf'),
                              style: Styles.textStyle16Meduim.copyWith(
                                color: AppColors.mentionBlue,
                              ),
                            ),
                            Gap(8.h),
                            Text(
                              textAlign: TextAlign.center,
                              context.tr('certificate_image_requirements'),
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.secondary400,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    AddCertificateCubit cubit,
    AddCertificateState state,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Directionality(
              textDirection: ui.TextDirection.rtl, // ⭐ تعيين الاتجاه للتقويم
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.kprimaryColor,
                    onPrimary: Colors.white,
                    onSurface: AppColors.secondary800,
                  ),
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(
                      fontFamily: 'ArabicFont',
                    ), // ⭐ إضافة خط عربي
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (picked != null) {
          cubit.updateDate(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(12.r),
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
                    ? DateFormat('yyyy').format(state.date!)
                    : context.tr('certificate_year_obtained'),
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
