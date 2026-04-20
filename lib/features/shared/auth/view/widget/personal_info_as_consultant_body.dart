import 'package:tayseer/features/shared/auth/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/age_selection_view.dart';
import 'package:tayseer/my_import.dart';

class PersonalInfoAsConsultantBody extends StatefulWidget {
  const PersonalInfoAsConsultantBody({super.key});

  @override
  State<PersonalInfoAsConsultantBody> createState() =>
      _PersonalInfoAsConsultantBodyState();
}

class _PersonalInfoAsConsultantBodyState
    extends State<PersonalInfoAsConsultantBody> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAge;

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── المحتوى القابل للتمرير ──
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      Text(
                        context.tr('enterPersonalInfo'),
                        style: Styles.textStyle20Bold.copyWith(
                          color: AppColors.kscandryTextColor,
                        ),
                      ),

                      SizedBox(height: context.height * 0.009),

                      Text(
                        textAlign: TextAlign.center,
                        context.tr('personalInfoHint'),
                        style: Styles.textStyle12,
                      ),
                      SizedBox(height: context.height * 0.02),
                      Text(
                        context.tr('upload_Photo'),
                        style: Styles.textStyle14,
                      ),
                      SizedBox(height: context.height * 0.02),
                      Center(
                        child: UploadImageFormField(
                          initialValue: authCubit.pickedImage,
                          isShowImage: true,
                          onImagePicked: (image) {
                            authCubit.pickedImage = image;
                          },
                          validator: (v) =>
                              v == null ? context.tr('required_images') : null,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          context.tr('uploadClearPhoto'),
                          style: Styles.textStyle12.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      CustomTextFormField(
                        controller: authCubit.nameAsConsultantController,
                        isName: true,
                      ),

                      const SizedBox(height: 16),

                      CustomDropdownFormField<String>(
                        hint: context.tr('gender'),
                        value: authCubit.selectedGender,
                        items: [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text(
                              context.tr('male'),
                              style: Styles.textStyle12,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text(
                              context.tr('female'),
                              style: Styles.textStyle12,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          authCubit.selectedGender = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return context.tr('completeAllData');
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      FormField<int>(
                        initialValue: _selectedAge,
                        validator: (value) {
                          if (value == null) return context.tr('required');
                          if (value < 30) {
                            return context.tr('age_must_be_over_30');
                          }
                          return null;
                        },
                        builder: (field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AgeSelectionView(
                                        initialAge: _selectedAge ?? 30,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    final age = int.tryParse(result);
                                    if (age != null) {
                                      setState(() {
                                        _selectedAge = age;
                                        final birthYear =
                                            DateTime.now().year - age;
                                        authCubit.birthDate = DateTime(
                                          birthYear,
                                          1,
                                          1,
                                        );
                                      });
                                      field.didChange(age);
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.height * .022,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.kWhiteColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: field.hasError
                                          ? Colors.red
                                          : AppColors.kprimaryColor.withOpacity(
                                              0.5,
                                            ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedAge != null
                                            ? '${context.tr('age_title')}: $_selectedAge'
                                            : context.tr('age_title'),
                                        style: Styles.textStyle12.copyWith(
                                          color: _selectedAge != null
                                              ? AppColors.blackColor
                                              : AppColors.kprimaryColor
                                                    .withOpacity(0.5),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.kprimaryColor
                                            .withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    right: 12,
                                  ),
                                  child: Text(
                                    field.errorText!,
                                    style: Styles.textStyle10.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: context.height * 0.03),
                    ],
                  ),
                ),
              ),

              // ── زرار Next ثابت في الأسفل ──
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: CustomBotton(
                  width: context.width,
                  useGradient: true,
                  title: context.tr('next'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (authCubit.selectedGender == null ||
                          _selectedAge == null ||
                          authCubit.pickedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            context,
                            text: context.tr('completeAllData'),
                            isError: true,
                          ),
                        );
                        return;
                      }

                      context.pushNamed(AppRouter.kConsultantInfoView);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
