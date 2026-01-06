import 'package:tayseer/core/functions/pac_date.dart';
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
                    child: UploadImageWidget(
                      isShowImage: true,
                      onImagePicked: (image) {
                        authCubit.pickedImage = image;
                      },
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

                  /// ➜ Birth Date
                  GestureDetector(
                    onTap: () async {
                      final date = await pickDate(context);

                      if (date != null) {
                        setState(() {
                          authCubit.birthDate = date;
                        });
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
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.kprimaryColor.withOpacity(0.3),
                          ),
                          SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              width: 10,
                              thickness: 1.5,
                              color: AppColors.kprimaryColor.withOpacity(0.3),
                            ),
                          ),
                          Text(
                            authCubit.birthDate == null
                                ? context.tr('birthDate')
                                : '${authCubit.birthDate!.day}/${authCubit.birthDate!.month}/${authCubit.birthDate!.year}',
                            style: Styles.textStyle12.copyWith(
                              color: authCubit.birthDate == null
                                  ? AppColors.kprimaryColor.withOpacity(0.5)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
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
