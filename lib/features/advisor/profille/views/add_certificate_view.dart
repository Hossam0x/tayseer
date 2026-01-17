import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class AddCertificateView extends StatelessWidget {
  const AddCertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    final certificatesRepository = getIt<CertificatesRepository>();

    return BlocProvider(
      create: (context) => AddCertificateCubit(certificatesRepository),
      child: Scaffold(
        body: BlocBuilder<AddCertificateCubit, AddCertificateState>(
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
                            SimpleAppBar(title: 'إضافة شهادة'),
                            // Certificate Image / Preview
                            _buildImagePickerSection(cubit, state),
                            Gap(32.h),
                            // Name Certificate field
                            ProfileTextField(
                              controller: state.nameCertificateController,
                              onChanged: cubit.updateNameCertificate,
                              hint: 'اسم الشهادة (مثال: بكالوريوس علم النفس)',
                            ),

                            Gap(20.h),

                            ProfileTextField(
                              controller: state.fromWhereController,
                              onChanged: cubit.updateFromWhere,
                              hint: 'من أين (مثال: جامعة الملك فيصل)',
                            ),
                            Gap(20.h),
                            // Date picker
                            _buildDatePicker(context, cubit, state),
                            Gap(24.h),
                            // Add Button
                            CustomBotton(
                              width: context.width * 0.8,
                              title: state.isLoading
                                  ? 'جاري الإضافة....'
                                  : 'إضافة',
                              useGradient: true,
                              onPressed: state.isLoading
                                  ? null
                                  : () => cubit.addCertificate(context),
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
    );
  }

  Widget _buildImagePickerSection(
    AddCertificateCubit cubit,
    AddCertificateState state,
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
                              'تحميل صورة أو pdf',
                              style: Styles.textStyle16Meduim.copyWith(
                                color: AppColors.mentionBlue,
                              ),
                            ),
                            Gap(8.h),
                            Text(
                              textAlign: TextAlign.center,
                              ' يجب ان تكون واضحة مع التأكد من أن جميع التفاصيل قابلة للقراءة دون تشويش',
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
      onTap: () => cubit.pickDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Row(
          children: [
            AppImage(AssetsData.calenderIcon),
            SizedBox(
              width: 30,
              height: 20,
              child: VerticalDivider(color: AppColors.primary100, thickness: 2),
            ),
            Expanded(
              child: Text(
                state.date != null
                    ? DateFormat('yyyy').format(state.date!)
                    : 'سنة الحصول عليها',
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
