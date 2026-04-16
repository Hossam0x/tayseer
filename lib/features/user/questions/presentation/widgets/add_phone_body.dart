import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class AddPhoneBody extends StatelessWidget {
  /// لو مش null، هيتم استدعاؤه بدل الـ navigation الافتراضي بعد النجاح
  final VoidCallback? onSuccessOverride;

  const AddPhoneBody({super.key, this.onSuccessOverride});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocConsumer<QuestionsCubit, QuestionsState>(
        listener: (context, state) {
          if (state.phoneNumberState == CubitStates.failure) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                text: state.errorMessage ?? context.tr('error'),
              ),
            );
          } else if (state.phoneNumberState == CubitStates.success) {
            context.pop();
            if (onSuccessOverride != null) {
              // ✅ لو في override (جاي من TicketSession) نستدعيه
              onSuccessOverride!();
            } else {
              // الـ flow الافتراضي
              context.pushReplacementNamed(AppRouter.kCommitmentView);
            }
          } else if (state.phoneNumberState == CubitStates.loading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CustomloadingApp()),
            );
          }
        },
        builder: (context, state) {
          final cubit = getIt<QuestionsCubit>();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: cubit.phoneFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(context.height * 0.02),

                    // زر الرجوع
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 25,
                        ),
                      ),
                    ),

                    Gap(context.height * 0.02),

                    // العنوان
                    Text(
                      context.tr("add_phone"),
                      style: Styles.textStyle20Bold.copyWith(
                        color: AppColors.kscandryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(context.height * 0.02),
                    Text(
                      context.tr("add_phone_desc"),
                      style: Styles.textStyle12Bold.copyWith(
                        color: AppColors.kgreyColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(context.height * 0.05),

                    CustomTextFormField(
                      isPhoneWithCountryCode: true,
                      controller: cubit.phoneController,
                      countryCodeController: cubit.countryCodeController,
                    ),
                    Gap(context.height * 0.08),

                    CustomBotton(
                      useGradient: true,
                      title: context.tr('next'),
                      onPressed: () {
                        cubit.sendPhoneNumber();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
