import 'package:tayseer/features/advisor/profille/view_model/models/certificate_model_profile.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateView extends StatelessWidget {
  final CertificateModelProfile certificate;

  const EditCertificateView({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditCertificateCubit()..initWithCertificate(certificate),
      child: Scaffold(
        body: BlocBuilder<EditCertificateCubit, EditCertificateState>(
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
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'تعديل الشهادات',
                              style: Styles.textStyle20Bold,
                            ),
                            // Certificate Image / Preview
                            _buildImagePickerSection(cubit, state),

                            Gap(32.h),

                            // Degree field
                            _buildTextField(
                              initialValue: state.degree,
                              onChanged: cubit.updateDegree,
                              hint: 'بكالوريوس علم النفس',
                            ),

                            Gap(20.h),

                            // University field
                            _buildTextField(
                              initialValue: state.university,
                              onChanged: cubit.updateUniversity,
                              hint: 'جامعة الملك فيصل',
                            ),

                            Gap(20.h),

                            // Graduation year
                            _buildYearPicker(context, cubit, state),

                            Gap(45.h),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: GestureDetector(
                                onTap: state.isLoading
                                    ? null
                                    : () => cubit.saveChanges(context),
                                child: Container(
                                  width: double.infinity,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary200,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(
                                    child: state.isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'اضافه',
                                            style: Styles.textStyle18SemiBold
                                                .copyWith(
                                                  color: AppColors.kWhiteColor,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Gap(20.h),
                            CustomBotton(
                              width: context.width * 0.9,
                              useGradient: true,
                              title: 'حفظ',
                              onPressed: () {},
                            ),
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
    EditCertificateCubit cubit,
    EditCertificateState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap(50.h),
        Stack(
          children: [
            Container(
              height: 150.h,
              width: 155.w,
              decoration: BoxDecoration(
                color: AppColors.hintText,
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: AppColors.primary100, width: 1.5),
              ),
              child: state.certificateImageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: Image.file(
                        state.certificateImageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : state.certificateImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: AppImage(
                        state.certificateImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 40.w,
                            color: AppColors.primary300,
                          ),
                          Gap(8.h),
                          Text(
                            'اضغط لإضافة/تغيير الصورة',
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            Positioned(
              bottom: 6,
              right: 6,
              child: GestureDetector(
                onTap: cubit.pickCertificateImage,
                child: AppImage(AssetsData.addCertificateImage),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: cubit.pickCertificateImage,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.kWhiteColor,
                  ),
                  child: Icon(Icons.close, color: AppColors.primary500),
                ),
              ),
            ),
          ],
        ),
        Gap(8.h),
        Text(
          'يرجى رفع صورة واضحة للشهادة الأكاديمية، مع التأكد من أن جميع التفاصيل قابلة للقراءة دون تشويش',
          style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Styles.textStyle14.copyWith(
              color: AppColors.secondary400,
            ),
            filled: true,
            fillColor: AppColors.kWhiteColor,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary100),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary500, width: 2.0),
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker(
    BuildContext context,
    EditCertificateCubit cubit,
    EditCertificateState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => cubit.pickGraduationYear(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary100, width: 1.0),
            ),
            child: Row(
              children: [
                AppImage(AssetsData.calenderIcon),
                SizedBox(
                  width: 30,
                  height: 20,
                  child: VerticalDivider(
                    color: AppColors.primary100,
                    thickness: 2,
                  ),
                ),
                Expanded(
                  child: Text(
                    state.graduationYear?.toString() ?? 'اختر السنة',
                    style: Styles.textStyle14.copyWith(
                      color: state.graduationYear == null
                          ? AppColors.secondary400
                          : AppColors.secondary800,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
