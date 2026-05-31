import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/phone/phone_edit_cubit.dart';
import 'package:tayseer/my_import.dart';

/// شاشة إضافة رقم الهاتف في الـ onboarding.
///
/// [onSuccessOverride] : لو مش null يُستدعى بدل الـ navigation الافتراضي.
class AddPhoneBody extends StatefulWidget {
  final VoidCallback? onSuccessOverride;

  const AddPhoneBody({super.key, this.onSuccessOverride});

  @override
  State<AddPhoneBody> createState() => _AddPhoneBodyState();
}

class _AddPhoneBodyState extends State<AddPhoneBody> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PhoneEditCubit>()
            ..initializePhone('', deviceCountry: resolveDefaultCountry()),
      child: CustomBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: BlocConsumer<QuestionsCubit, QuestionsState>(
            listener: _handleQuestionsState,
            builder: (context, questionsState) {
              return BlocBuilder<PhoneEditCubit, PhoneEditState>(
                builder: (context, phoneState) {
                  _syncController(phoneState);

                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Gap(context.height * 0.02),
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
                          Text(
                            context.tr('add_phone'),
                            style: Styles.textStyle20Bold.copyWith(
                              color: AppColors.kscandryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Gap(context.height * 0.02),
                          Text(
                            context.tr('add_phone_desc'),
                            style: Styles.textStyle12Bold.copyWith(
                              color: AppColors.kgreyColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Gap(context.height * 0.05),
                          PhoneInputField(
                            controller: _phoneController,
                            selectedCountry: phoneState.selectedCountry,
                            phoneError: phoneState.visibleError.isNotEmpty
                                ? context.tr(phoneState.visibleError)
                                : '',
                            onCountryTap: () => showCountryPickerSheet(
                              context,
                              currentCode: phoneState.selectedCountry.code,
                              onSelected: (country) => context
                                  .read<PhoneEditCubit>()
                                  .updateCountry(country),
                            ),
                            onPhoneChanged: (value) => context
                                .read<PhoneEditCubit>()
                                .updatePhoneNumber(value),
                          ),
                          const Spacer(),
                          CustomBotton(
                            useGradient: true,
                            title: context.tr('next'),
                            onPressed: phoneState.canProceed
                                ? () => _submit(context, phoneState)
                                : null,
                          ),
                          Gap(context.height * 0.03),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _syncController(PhoneEditState state) {
    if (_phoneController.text != state.phoneNumber) {
      _phoneController.text = state.phoneNumber;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: state.phoneNumber.length),
      );
    }
  }

  void _submit(BuildContext context, PhoneEditState phoneState) {
    final questionsCubit = context.read<QuestionsCubit>();
    questionsCubit.phoneController.text = phoneState.phoneNumber;
    questionsCubit.countryCodeController.text = phoneState.selectedCountry.code;
    questionsCubit.sendPhoneNumber();
  }

  void _handleQuestionsState(BuildContext context, QuestionsState state) {
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
      if (widget.onSuccessOverride != null) {
        widget.onSuccessOverride!();
      } else {
        context.pushReplacementNamed(AppRouter.kCommitmentView);
      }
    } else if (state.phoneNumberState == CubitStates.loading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CustomloadingApp()),
      );
    }
  }
}
