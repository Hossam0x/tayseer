import 'package:tayseer/core/widgets/custom_date_picker_field.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),

                  Text(
                    context.tr('enterPersonalInfo'),
                    style: Styles.textStyle18.copyWith(
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
                  Text(context.tr('upload_Photo'), style: Styles.textStyle14),
                  SizedBox(height: context.height * 0.02),
                  Center(
                    child: UploadImageFormField(
                      initialValue: authCubit.pickedImage,
                      isShowImage: true,
                      onImagePicked: (image) {
                        authCubit.pickedImage = image;
                      },
                      validator: (v) =>
                          v == null ? context.tr('required') : null,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      context.tr('uploadClearPhoto'),
                      style: Styles.textStyle12.copyWith(color: Colors.grey),
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

                  DatePickerField(
                    initialValue: authCubit.birthDate,
                    placeholder: context.tr('birthDate'),
                    onDateChanged: (date) {
                      setState(() {
                        authCubit.birthDate = date;
                      });
                    },
                    validator: (value) {
                      if (value == null) return context.tr('required');
                      final now = DateTime.now();
                      int age = now.year - value.year;
                      if (now.month < value.month ||
                          (now.month == value.month && now.day < value.day)) {
                        age--;
                      }
                      return age < 30
                          ? context.tr('age_must_be_over_30')
                          : null;
                    },
                  ),

                  SizedBox(height: context.height * 0.03),

                  /// ➜ Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CustomBotton(
                      width: context.width,
                      useGradient: true,
                      title: context.tr('next'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (authCubit.selectedGender == null ||
                              authCubit.birthDate == null ||
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
        ),
      ),
    );
  }
}
