import 'package:tayseer/core/functions/pac_date.dart';
import 'package:tayseer/features/shared/auth/view/widget/certificate_card.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class ConsultantUploadCertificateBody extends StatelessWidget {
  const ConsultantUploadCertificateBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: GlobalKey<FormState>(),
              child: BlocBuilder<AuthCubit, AuthState>(
                bloc: authCubit,
                builder: (context, state) {
                  final isAdding =
                      state.addCertificateState == CubitStates.loading;
                  return Column(
                    children: [
                      /// Back
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      /// Title
                      Text(
                        context.tr('shareYourCertificates'),
                        style: Styles.textStyle18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.kscandryTextColor,
                        ),
                      ),

                      Gap(context.responsiveHeight(8)),

                      Text(
                        context.tr('certificateUploadHint'),
                        style: Styles.textStyle12,
                        textAlign: TextAlign.center,
                      ),

                      Gap(context.responsiveHeight(32)),

                      /// Upload Image
                      UploadImageWidget(
                        isShowImage: true,
                        initialImage: authCubit.pickedCertificate,
                        onImagePicked: (image) {
                          authCubit.setPickedCertificate(image);
                        },
                      ),
                      Gap(context.responsiveHeight(8)),
                      if (authCubit.certificates.isNotEmpty)
                        Text(
                          context.tr('uploadCertificateImageSubTitle'),
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.kgreyColor,
                          ),
                        ),
                      Gap(context.responsiveHeight(12)),
                      Text(
                        context.tr('uploadCertificateImageHint'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(context.responsiveHeight(24)),

                      /// Certificate Name
                      CustomTextFormField(
                        controller: authCubit.certificateNameController,
                        hintText: context.tr('certificateName'),
                        validator: (v) => v == null || v.isEmpty
                            ? context.tr('required')
                            : null,
                      ),

                      Gap(context.responsiveHeight(16)),

                      /// Institution
                      CustomTextFormField(
                        controller: authCubit.institutionNameController,
                        hintText: context.tr('institutionName'),
                        validator: (v) => v == null || v.isEmpty
                            ? context.tr('required')
                            : null,
                      ),

                      Gap(context.responsiveHeight(16)),

                      /// Date
                      GestureDetector(
                        onTap: () async {
                          final date = await pickDate(context);
                          if (date != null) {
                            authCubit.setObtainDate(date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.kprimaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.kprimaryColor.withOpacity(0.4),
                              ),
                              Gap(context.responsiveWidth(8)),
                              Text(
                                authCubit.obtainDate == null
                                    ? context.tr('yearOfObtainment')
                                    : authCubit.obtainDate!.year.toString(),
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.kprimaryColor.withOpacity(
                                    0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Gap(context.responsiveHeight(32)),

                      /// Add Button
                      CustomBotton(
                        useGradient: true,
                        width: context.width,

                        title: isAdding
                            ? context.tr('loading')
                            : context.tr('add'),
                        onPressed: isAdding
                            ? null
                            : () async {
                                await authCubit.addCertificateAsConsultant();
                              },
                      ),

                      /// Certificates List
                      if (authCubit.certificates.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: authCubit.certificates
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final cert = entry.value;

                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 350 + index * 80,
                                    ),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) {
                                      final opacity = value.clamp(0.0, 1.0);
                                      final scale = 0.85 + (value * 0.15);

                                      return Opacity(
                                        opacity: opacity,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: CertificateCard(certificate: cert),
                                  );
                                })
                                .toList(),
                          ),
                        ),

                      Gap(context.responsiveHeight(32)),

                      /// Next
                      CustomBotton(
                        useGradient: authCubit.certificates.isEmpty
                            ? false
                            : true,
                        backGroundcolor: AppColors.kgreyColor,
                        width: context.width,
                        title: context.tr('next'),
                        onPressed: authCubit.certificates.isEmpty
                            ? null
                            : () {
                                context.pushNamed(
                                  AppRouter.kUploadNationalidView,
                                );
                              },
                      ),

                      Gap(context.responsiveHeight(20)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
