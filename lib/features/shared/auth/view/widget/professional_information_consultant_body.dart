import 'package:tayseer/core/utils/helper/video_picker_helper.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class ProfessionalInformationAsConsultantBody extends StatelessWidget {
  ProfessionalInformationAsConsultantBody({super.key});

  final _formKey = GlobalKey<FormState>();
  final _videoPicker = VideoPickerHelper();

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
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      /// ➜ Title
                      Text(
                        context.tr('enterProfessionalInfo'),
                        style: Styles.textStyle18.copyWith(
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
                        items: [
                          DropdownMenuItem(
                            value: 'psychology',
                            child: Text(
                              'هندسه قسم اتصالات',
                              style: Styles.textStyle14,
                            ),
                          ),
                        ],
                        onChanged: authCubit.setSpecialization,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Job Level
                      CustomDropdownFormField<String>(
                        hint: context.tr('jobLevel'),
                        value: authCubit.jobLevel,
                        items: [
                          DropdownMenuItem(
                            value: 'junior',
                            child: Text(
                              context.tr('junior'),
                              style: Styles.textStyle14,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'senior',
                            child: Text(
                              context.tr('senior'),
                              style: Styles.textStyle14,
                            ),
                          ),
                        ],
                        onChanged: authCubit.setJobLevel,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Experience Years
                      CustomDropdownFormField<String>(
                        hint: context.tr('experienceYears'),
                        value: authCubit.experienceYears,
                        items: [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('1', style: Styles.textStyle14),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('2', style: Styles.textStyle14),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('3', style: Styles.textStyle14),
                          ),
                        ],
                        onChanged: authCubit.setExperienceYears,
                        validator: (value) =>
                            value == null ? context.tr('required') : null,
                      ),

                      const SizedBox(height: 16),

                      /// ➜ Bio
                      CustomTextFormField(
                        controller: authCubit.bioController,
                        hintText: context.tr('bio'),
                        maxLines: 8,
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
                            context.pushNamed(
                              AppRouter.kConsultantUploadCertificateView,
                            );
                          } else if (state.personalDataState ==
                              CubitStates.failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                context,
                                text:
                                    state.errorMessage ??
                                    'حدث خطأ أثناء إرسال البيانات ❌',
                                isError: true,
                              ),
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
                              authCubit.submitPersonalDataAsConsultant();
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
