import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart'
    show CertificateModel;
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class EditCertificateView extends StatelessWidget {
  final List<CertificateModel> certificates;

  const EditCertificateView({super.key, required this.certificates});

  @override
  Widget build(BuildContext context) {
    // ⭐ استخدم نفس الـ repository من الـ CertificatesCubit
    final certificatesRepository = getIt<CertificatesRepository>();

    return BlocProvider(
      create: (context) => EditCertificateCubit(certificatesRepository),
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
                              alignment: Alignment.centerRight,
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
                              'إضافة / تعديل الشهادات',
                              style: Styles.textStyle20Bold,
                            ),
                            // Certificate Image / Preview
                            _buildImagePickerSection(cubit, state),
                            Gap(32.h),
                            // Name Certificate field
                            _buildTextField(
                              controller: state.nameCertificateController!,
                              onChanged: cubit.updateNameCertificate,
                              hint: 'اسم الشهادة (مثال: بكالوريوس علم النفس)',
                            ),
                            Gap(20.h),
                            // From Where field
                            _buildTextField(
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
                              width: double.infinity,
                              height: 56.h,
                              child: GestureDetector(
                                onTap: state.isLoading
                                    ? null
                                    : () => cubit.addCertificate(context),
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
                                            'اضافة',
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
                              Text(
                                'الشهادات الحالية - اضغط للتعديل',
                                style: Styles.textStyle16Meduim.copyWith(
                                  color: AppColors.secondary800,
                                ),
                              ),
                              Gap(12.h),
                              SizedBox(
                                height: 120.h,
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
                                        width: 100.w,
                                        margin: EdgeInsets.only(left: 12.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.kprimaryColor
                                                : AppColors.primary100,
                                            width: isSelected ? 3 : 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(
                                                        12.r,
                                                      ),
                                                    ),
                                                child: cert.image != null
                                                    ? CachedNetworkImage(
                                                        imageUrl: cert.image!,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
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
                                                              color: Colors
                                                                  .grey
                                                                  .shade200,
                                                              child: Icon(
                                                                Icons.image,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                              ),
                                                            ),
                                                      )
                                                    : Container(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        child: Icon(
                                                          Icons.school,
                                                          color: Colors
                                                              .grey
                                                              .shade400,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(6.w),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.kprimaryColor
                                                          .withOpacity(0.1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                        12.r,
                                                      ),
                                                    ),
                                              ),
                                              child: Text(
                                                cert.nameCertificate,
                                                style: Styles.textStyle12
                                                    .copyWith(
                                                      color: isSelected
                                                          ? AppColors
                                                                .kprimaryColor
                                                          : AppColors
                                                                .secondary800,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
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
                              width: context.width * 0.9,
                              useGradient: true,
                              title: 'حفظ',
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
                            textAlign: TextAlign.center,
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
            if (state.certificateImageFile != null ||
                state.certificateImageUrl != null)
              Positioned(
                top: 10,
                right: 10,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    return TextFormField(
      controller: controller, // ⭐ استخدم controller بدل initialValue
      onChanged: onChanged,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Styles.textStyle14.copyWith(color: AppColors.secondary400),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

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
          border: Border.all(color: AppColors.primary100, width: 1.0),
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
                      ? AppColors.secondary400
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
