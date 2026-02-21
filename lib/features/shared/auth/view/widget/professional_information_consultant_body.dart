import 'package:tayseer/core/utils/helper/video_picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class ProfessionalInformationAsConsultantBody extends StatefulWidget {
  const ProfessionalInformationAsConsultantBody({super.key});

  @override
  State<ProfessionalInformationAsConsultantBody> createState() =>
      _ProfessionalInformationAsConsultantBodyState();
}

class _ProfessionalInformationAsConsultantBodyState
    extends State<ProfessionalInformationAsConsultantBody> {
  final _formKey = GlobalKey<FormState>();

  final _videoPicker = VideoPickerHelper();

  final List<String> specializationKeys = [
    'marital_counseling',
    'premarital_counseling',
    'parenting_counseling',
    'children_issues',
    'adolescent_issues',
    'extended_family_relations',
    'domestic_violence_protection',
    'family_crisis_management',
    'divorce_counseling',
    'marital_sexual_counseling',
    'family_addiction',
    'family_mental_health',
  ];
  final List<String> jobLevelKeys = [
    'junior_counselor',
    'senior_counselor',
    'specialist_consultant',
    'lead_consultant',
  ];

  final List<String> experienceYearsKeys = [
    'experience_0_2',
    'experience_2_5',
    'experience_5_10',
    'experience_10_plus',
  ];
  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// ➜ Back
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      /// ➜ Title
                      Text(
                        context.tr('enterProfessionalInfo'),
                        style: Styles.textStyle20Bold.copyWith(
                          color: AppColors.kscandryTextColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        context.tr('professionalInfoHint'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ➜ Specialization
                      CustomDropdownFormField<String>(
                        hint: context.tr('specialization'),
                        value: authCubit.specialization,
                        items: specializationKeys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(
                                  context.tr(key),
                                  style: Styles.textStyle14,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: authCubit.setSpecialization,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Job Level
                      CustomDropdownFormField<String>(
                        hint: context.tr('jobLevel'),
                        value: authCubit.jobLevel,
                        items: jobLevelKeys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(
                                  context.tr(key),
                                  style: Styles.textStyle14,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: authCubit.setJobLevel,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Experience Years
                      CustomDropdownFormField<String>(
                        hint: context.tr('experienceYears'),
                        value: authCubit.experienceYears,
                        items: experienceYearsKeys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(
                                  context.tr(key),
                                  style: Styles.textStyle14,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: authCubit.setExperienceYears,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),
                      const SizedBox(height: 16),

                      /// ➜ Bio
                      CustomTextFormField(
                        controller: authCubit.bioController,
                        onChanged: authCubit.updateText,
                        hintText: context.tr('bio'),
                        maxLines: 8,
                      ),
                      const SizedBox(height: 16),

                      /// ➜ AI Content Generation Button
                      CusttomGlassButton(
                        text: context.tr('generate_ai_content'),
                        showIcon: state.isAiState == CubitStates.loading,

                        onTap: () {
                          authCubit.enhanceTextWithGemini(context);
                        },
                      ),
                      const SizedBox(height: 24),

                      /// ➜ Upload Video
                      UploadVideoWidget(
                        onTap: () async {
                          final video = await _videoPicker.pickFromGallery();
                          if (video != null) {
                            authCubit.setPickedVideo(video);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Video Preview
                      if (authCubit.pickedVideo != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomUploadedVideoPreview(
                                video: authCubit.pickedVideo!,
                                onRemove: authCubit.removePickedVideo,
                                onInitialized: () => authCubit.setVideoLoaded(),
                              ),
                              if (authCubit.isVideoLoading)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.35),
                                    child: const Center(
                                      child: CustomloadingApp(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      /// ➜ Button
                      BlocConsumer<AuthCubit, AuthState>(
                        listenWhen: (previous, current) =>
                            previous.personalDataState !=
                            current.personalDataState,
                        listener: (context, state) {
                          if (state.personalDataState == CubitStates.success) {
                            context.pop(); // Close loading dialog
                            context.pushNamed(
                              AppRouter.kConsultantUploadCertificateView,
                            );
                          } else if (state.personalDataState ==
                              CubitStates.failure) {
                            context.pop(); // Close loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                context,
                                text:
                                    state.errorMessage ??
                                    'حدث خطأ أثناء إرسال البيانات ❌',
                                isError: true,
                              ),
                            );
                          } else if (state.personalDataState ==
                              CubitStates.loading) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return Center(child: const CustomloadingApp());
                              },
                            );
                          }
                        },
                        builder: (context, state) {
                          return CustomBotton(
                            width: context.width,
                            useGradient: true,
                            title:
                                state.personalDataState == CubitStates.loading
                                ? context.tr('sending')
                                : context.tr('next'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                authCubit.submitPersonalDataAsConsultant();
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),
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
