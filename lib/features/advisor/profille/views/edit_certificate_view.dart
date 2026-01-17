import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart'
    show CertificateModel;
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
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
                            SimpleAppBar(
                              title: ' تعديل الشهادات',
                              isLargeTitle: true,
                            ),
                            // Certificate Image / Preview
                            _buildImagePickerSection(cubit, state),
                            Gap(32.h),
                            // Name Certificate field
                            ProfileTextField(
                              controller: state.nameCertificateController!,
                              onChanged: cubit.updateNameCertificate,
                              hint: 'اسم الشهادة (مثال: بكالوريوس علم النفس)',
                            ),

                            Gap(20.h),

                            ProfileTextField(
                              controller: state.fromWhereController!,
                              onChanged: cubit.updateFromWhere,
                              hint: 'من أين (مثال: جامعة الملك فيصل)',
                            ),
                            Gap(20.h),
                            // Date picker
                            _buildDatePicker(context, cubit, state),
                            Gap(24.h),
                            // Add Button
                            SizedBox(
                              width: context.width * 0.8,
                              height: 56.h,
                              child: GestureDetector(
                                onTap: state.isLoading
                                    ? null
                                    : () => cubit.updateCertificate(context),
                                child: Container(
                                  width: context.width * 0.8,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary400,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: state.isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'تحديث',
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
                            // Certificates List
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
                                        state.selectedCertificateId == cert.id;

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
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              placeholder: (context, url) => Container(
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(
                                                                    color: AppColors
                                                                        .kprimaryColor,
                                                                    strokeWidth:
                                                                        2.w,
                                                                  ),
                                                                ),
                                                              ),
                                                              errorWidget:
                                                                  (
                                                                    context,
                                                                    url,
                                                                    error,
                                                                  ) => Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    child: Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .image,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        size: 40
                                                                            .w,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            )
                                                          : Container(
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              color: Colors
                                                                  .grey
                                                                  .shade200,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.school,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  size: 40.w,
                                                                ),
                                                              ),
                                                            ),

                                                      // علامة Edit في الشمال
                                                      Positioned(
                                                        top: 4.r,
                                                        left: 4.r,
                                                        child: AppImage(
                                                          AssetsData.editIcon,
                                                          width: 20.w,
                                                        ),
                                                      ),

                                                      // علامة X في اليمين
                                                      Positioned(
                                                        top: 4.r,
                                                        right: 4.r,
                                                        child: Container(
                                                          width: 24.r,
                                                          height: 24.r,
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 20.r,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h,
                                              ),
                                              // decoration: BoxDecoration(
                                              //   color: isSelected
                                              //       ? AppColors.kprimaryColor
                                              //             .withOpacity(0.1)
                                              //       : Colors.transparent,
                                              //   borderRadius:
                                              //       BorderRadius.vertical(
                                              //         bottom: Radius.circular(
                                              //           12.r,
                                              //         ),
                                              //       ),
                                              // ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    cert.nameCertificate,
                                                    style: Styles.textStyle16
                                                        .copyWith(
                                                          color: AppColors
                                                              .primaryText,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Gap(4.h),
                                                  Text(
                                                    cert.fromWhere,
                                                    style: Styles.textStyle16
                                                        .copyWith(
                                                          color: AppColors
                                                              .primaryText,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Gap(4.h),
                                                  Text(
                                                    DateFormat(
                                                      'yyyy',
                                                    ).format(cert.date),
                                                    style: Styles.textStyle16
                                                        .copyWith(
                                                          color: AppColors
                                                              .primaryText,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Gap(20.h),
                            ],
                            // Save Button
                            CustomBotton(
                              width: context.width * 0.8,
                              useGradient: true,
                              title: state.isLoading ? 'جارٍ الحفظ...' : 'حفظ',
                              onPressed: state.isLoading
                                  ? null
                                  : () => cubit.updateCertificate(context),
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
                color: Colors.grey.shade200,
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
                            Icons.school,
                            size: 40.w,
                            color: Colors.grey.shade500,
                          ),
                        ],
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
            if (state.certificateImageFile != null ||
                state.certificateImageUrl != null)
              Positioned(
                top: 12.r,
                right: 12.r,
                child: GestureDetector(
                  onTap: cubit.removeCertificateImage,
                  child: Container(
                    padding: EdgeInsets.all(4),
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
          'يرجى رفع صورة واضحة للشهادة الأكاديمية، مع التأكد من أن جميع التفاصيل قابلة للقراءة دون تشويش',
          style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required ValueChanged<String> onChanged,
  //   String? hint,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     onChanged: onChanged,
  //     textAlign: TextAlign.right,
  //     decoration: InputDecoration(
  //       hintText: hint,
  //       hintStyle: Styles.textStyle14.copyWith(color: AppColors.secondary400),
  //       filled: true,
  //       fillColor: AppColors.kWhiteColor,
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8.r),
  //         borderSide: BorderSide(color: AppColors.primary100),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8.r),
  //         borderSide: BorderSide(color: AppColors.primary500),
  //       ),
  //       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  //     ),
  //   );
  // }

  Widget _buildDatePicker(
    BuildContext context,
    EditCertificateCubit cubit,
    EditCertificateState state,
  ) {
    return GestureDetector(
      onTap: () => cubit.pickDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(8.r),
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
                    ? DateFormat('yyyy/MM/dd').format(state.date!)
                    : 'اختر التاريخ',
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
