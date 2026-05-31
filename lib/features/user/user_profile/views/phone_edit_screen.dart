import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/phone/phone_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/otp_user_screen.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

class PhoneEditScreen extends StatelessWidget {
  final String initialPhone;

  const PhoneEditScreen({super.key, this.initialPhone = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhoneEditCubit>()
        ..initializePhone(initialPhone, deviceCountry: resolveDefaultCountry()),
      child: const _PhoneEditBody(),
    );
  }
}

class _PhoneEditBody extends StatefulWidget {
  const _PhoneEditBody();

  @override
  State<_PhoneEditBody> createState() => _PhoneEditBodyState();
}

class _PhoneEditBodyState extends State<_PhoneEditBody> {
  late final TextEditingController _phoneController;
  late final FocusNode _phoneFocusNode;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneEditCubit, PhoneEditState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        _syncController(state);

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: AdvisorBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: SimpleAppBar(
                        title: context.tr('phone_title'),
                        isLargeTitle: true,
                      ),
                    ),
                    Gap(8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        context.tr('phone_verification_hint'),
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                    ),
                    Gap(100.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: PhoneInputField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        selectedCountry: state.selectedCountry,
                        phoneError: state.visibleError.isNotEmpty
                            ? context.tr(state.visibleError)
                            : '',
                        onCountryTap: () => showCountryPickerSheet(
                          context,
                          currentCode: state.selectedCountry.code,
                          onSelected: (country) => context
                              .read<PhoneEditCubit>()
                              .updateCountry(country),
                        ),
                        onPhoneChanged: (value) => context
                            .read<PhoneEditCubit>()
                            .updatePhoneNumber(value),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.w,
                        vertical: 30.h,
                      ),
                      child: CustomBotton(
                        height: 53.h,
                        width: double.infinity,
                        title: state.isLoading
                            ? context.tr('sending_status')
                            : context.tr('next'),
                        useGradient: true,
                        backGroundcolor: state.canProceed && !state.isLoading
                            ? Colors.transparent
                            : Colors.grey,
                        onPressed: state.isLoading || !state.canProceed
                            ? null
                            : () =>
                                  context.read<PhoneEditCubit>().updatePhone(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  void _handleStateChanges(BuildContext context, PhoneEditState state) {
    if (state.errorMessage.isNotEmpty) {
      AppToast.error(context, context.tr(state.errorMessage));
      context.read<PhoneEditCubit>().clearMessages();
    } else if (state.successMessage.isNotEmpty &&
        state.updatePhoneStatus == CubitStates.success) {
      AppToast.success(context, context.tr(state.successMessage));

      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (!mounted) return;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpUserScreen(
              phoneNumber: state.fullPhoneNumber,
              isPhoneUpdate: true,
              otpSource: OtpSource.editPhone,
            ),
          ),
        );

        if (mounted && result == null) Navigator.pop(context);
        if (mounted) context.read<PhoneEditCubit>().resetError();
      });

      context.read<PhoneEditCubit>().clearMessages();
    }
  }
}
