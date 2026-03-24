import 'package:chewie/chewie.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_avatar.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_dropdown.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_save_button.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_username_field.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_video_section.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataForm extends StatelessWidget {
  final EditPersonalDataCubit cubit;
  final EditPersonalDataState state;
  final EditPersonalDataUiCubit uiCubit;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final TextEditingController usernameController;
  final ChewieController? chewieController;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  static const _specializationKeys = [
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

  static const _jobLevelKeys = [
    'junior_counselor',
    'senior_counselor',
    'specialist_consultant',
    'lead_consultant',
  ];

  static const _experienceYearsKeys = [
    'experience_0_2',
    'experience_2_5',
    'experience_5_10',
    'experience_10_plus',
  ];

  const EditPersonalDataForm({
    super.key,
    required this.cubit,
    required this.state,
    required this.uiCubit,
    required this.nameController,
    required this.bioController,
    required this.usernameController,
    required this.chewieController,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: EditPersonalDataAvatar(
            cubit: cubit,
            state: state,
            onPickImage: onPickImage,
          ),
        ),
        Gap(20.h),
        BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
          buildWhen: (p, c) => p.nameError != c.nameError,
          builder: (context, _) => ProfileTextField(
            controller: nameController,
            maxLength: 24,
            minLength: 4,
            showCharacterCount: true,
            validationErrorKey: 'full_name_length_error',
            onChanged: (value) {
              uiCubit.validateName(value, context.tr('full_name_length_error'));
              cubit.updateName(value);
            },
            hint: context.tr("enter_name"),
          ),
        ),
        Gap(11.h),
        EditPersonalDataUsernameField(
          controller: usernameController,
          cubit: cubit,
          uiCubit: uiCubit,
        ),
        Gap(11.h),
        BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
          buildWhen: (p, c) =>
              p.selectedSpecialization != c.selectedSpecialization,
          builder: (context, uiState) => EditPersonalDataDropdown(
            value: uiState.selectedSpecialization,
            items: _specializationKeys,
            hint: 'select_specialization',
            onChanged: (v) {
              uiCubit.updateSelectedSpecialization(v);
              if (v != null) cubit.updateSpecialization(v);
            },
          ),
        ),
        Gap(11.h),
        BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
          buildWhen: (p, c) => p.selectedPosition != c.selectedPosition,
          builder: (context, uiState) => EditPersonalDataDropdown(
            value: uiState.selectedPosition,
            items: _jobLevelKeys,
            hint: 'select_position',
            onChanged: (v) {
              uiCubit.updateSelectedPosition(v);
              if (v != null) cubit.updatePosition(v);
            },
          ),
        ),
        Gap(11.h),
        BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
          buildWhen: (p, c) =>
              p.selectedExperienceDisplay != c.selectedExperienceDisplay,
          builder: (context, uiState) => EditPersonalDataDropdown(
            value: uiState.selectedExperienceDisplay,
            items: _experienceYearsKeys,
            hint: 'select_experience_years',
            onChanged: (v) {
              uiCubit.updateSelectedExperience(v, v);
              if (v != null) cubit.updateExperience(v);
            },
          ),
        ),
        Gap(11.h),
        ProfileTextField(
          controller: bioController,
          onChanged: cubit.updateBio,
          hint: context.tr("bio_hint"),
          maxLines: 4,
          maxLength: 250,
          minLength: 3,
          showCharacterCount: true,
          validationErrorKey: 'bio_min_3_chars',
        ),
        Gap(12.h),
        CusttomGlassButton(
          text: context.tr('generate_ai_content'),
          showIcon: state.isAiState == CubitStates.loading,
          onTap: () => cubit.enhanceTextWithGemini(context, bioController),
        ),
        Gap(25.h),
        EditPersonalDataVideoSection(
          cubit: cubit,
          state: state,
          chewieController: chewieController,
          onPickVideo: onPickVideo,
          onRemoveVideo: onRemoveVideo,
        ),
        Gap(35.h),
        EditPersonalDataSaveButton(state: state, bioController: bioController),
        Gap(40.h),
      ],
    );
  }
}
