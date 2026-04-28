import 'package:tayseer/core/widgets/custom_date_picker_field.dart';
import 'package:tayseer/features/shared/auth/view/widget/certificate_card.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class ConsultantUploadCertificateBody extends StatefulWidget {
  const ConsultantUploadCertificateBody({super.key});

  @override
  State<ConsultantUploadCertificateBody> createState() =>
      _ConsultantUploadCertificateBodyState();
}

class _ConsultantUploadCertificateBodyState
    extends State<ConsultantUploadCertificateBody> {
  final formkey = GlobalKey<FormState>();
  late final AuthCubit authCubit;
  bool _showAddForm = true;

  @override
  void initState() {
    super.initState();
    authCubit = getIt<AuthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formkey,
              child: BlocBuilder<AuthCubit, AuthState>(
                bloc: authCubit,
                builder: (context, state) {
                  final isAdding =
                      state.addCertificateState == CubitStates.loading;
                  final hasCertificates = authCubit.certificates.isNotEmpty;

                  return Column(
                    children: [
                      /// Back
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            if (_showAddForm && hasCertificates) {
                              setState(() => _showAddForm = false);
                            } else {
                              context.pop();
                            }
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      /// Title
                      Text(
                        context.tr('shareYourCertificates'),
                        style: Styles.textStyle20Bold.copyWith(
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

                      /// Add Form — shown when no certificates yet OR user tapped "add another"
                      if (_showAddForm) ...[
                        /// Upload Image
                        UploadImageFormField(
                          key: ValueKey(
                            authCubit.pickedCertificate?.path ?? 'no_image',
                          ),
                          isShowImage: true,
                          initialValue: authCubit.pickedCertificate,
                          onImagePicked: (image) {
                            authCubit.setPickedCertificate(image);
                          },
                          validator: (v) =>
                              v == null ? context.tr('required_images') : null,
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
                        DatePickerField(
                          initialValue: authCubit.obtainDate,
                          placeholder: context.tr('yearOfObtainment'),
                          onDateChanged: (date) {
                            if (date != null) authCubit.setObtainDate(date);
                          },
                          validator: (value) =>
                              value == null ? context.tr('required') : null,
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
                                  if (!formkey.currentState!.validate()) return;
                                  await authCubit.addCertificateAsConsultant();
                                  if (authCubit.certificates.isNotEmpty) {
                                    setState(() => _showAddForm = false);
                                  }
                                },
                        ),

                        Gap(context.responsiveHeight(16)),
                      ],

                      /// Certificates List
                      if (hasCertificates && !_showAddForm) ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: authCubit.certificates.asMap().entries.map((
                            entry,
                          ) {
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
                          }).toList(),
                        ),

                        Gap(context.responsiveHeight(24)),

                        /// Add Another Certificate Button
                        CustomBotton(
                          useGradient: true,
                          width: context.width,
                          title: context.tr('addAnotherCertificate'),
                          onPressed: () {
                            setState(() => _showAddForm = true);
                          },
                        ),

                        Gap(context.responsiveHeight(16)),

                        /// Next Button
                        CustomBotton(
                          useGradient: true,
                          backGroundcolor: AppColors.kgreyColor,
                          width: context.width,
                          title: context.tr('next'),
                          onPressed: () {
                            context.pushNamed(AppRouter.kUploadNationalidView);
                          },
                        ),

                        Gap(context.responsiveHeight(20)),
                      ],
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
