import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/phone/phone_edit_cubit.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UnifiedPhoneScreen
// ─────────────────────────────────────────────────────────────────────────────
//
// شاشة إدخال رقم الهاتف الموحدة — تُستخدم في:
//   • تعديل رقم الهاتف من البروفايل
//   • إضافة رقم الهاتف في الـ onboarding
//   • أي سيناريو مستقبلي يحتاج إدخال رقم
//
// بعد نجاح الـ API تنتقل تلقائياً لـ [UnifiedOtpScreen] مع نفس الـ otpSource
// وبعد نجاح الـ OTP تُرجع [true] للـ caller عبر [Navigator.pop].
//
// Params:
//   [initialPhone]   — الرقم الحالي (يُعرض مسبقاً في الحقل)
//   [otpSource]      — المصدر الذي يحدد الـ endpoint المستخدم
//   [title]          — عنوان الصفحة (اختياري، له قيمة افتراضية)
//   [hint]           — نص توضيحي تحت العنوان (اختياري)
//   [useLargeTitle]  — هل العنوان كبير (SimpleAppBar style)
//   [showMethodSelector] — هل يظهر selector لاختيار sms / whatsapp
// ─────────────────────────────────────────────────────────────────────────────

class UnifiedPhoneScreen extends StatelessWidget {
  final String initialPhone;
  final OtpSource otpSource;
  final String? titleKey;
  final String? hintKey;
  final bool useLargeTitle;
  final bool showMethodSelector;

  const UnifiedPhoneScreen({
    super.key,
    this.initialPhone = '',
    this.otpSource = OtpSource.editPhone,
    this.titleKey,
    this.hintKey,
    this.useLargeTitle = true,
    this.showMethodSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PhoneEditCubit>()
        ..initializePhone(
          initialPhone,
          deviceCountry: resolveDefaultCountry(context),
        ),
      child: _UnifiedPhoneBody(
        otpSource: otpSource,
        titleKey: titleKey,
        hintKey: hintKey,
        useLargeTitle: useLargeTitle,
        showMethodSelector: showMethodSelector,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UnifiedPhoneBody extends StatefulWidget {
  final OtpSource otpSource;
  final String? titleKey;
  final String? hintKey;
  final bool useLargeTitle;
  final bool showMethodSelector;

  const _UnifiedPhoneBody({
    required this.otpSource,
    this.titleKey,
    this.hintKey,
    this.useLargeTitle = true,
    this.showMethodSelector = true,
  });

  @override
  State<_UnifiedPhoneBody> createState() => _UnifiedPhoneBodyState();
}

class _UnifiedPhoneBodyState extends State<_UnifiedPhoneBody> {
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

                    // ── App Bar ──
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: widget.useLargeTitle
                          ? SimpleAppBar(
                              title: context.tr(
                                widget.titleKey ?? 'phone_title',
                              ),
                              isLargeTitle: true,
                            )
                          : Align(
                              alignment: isArabic
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                  size: 25,
                                ),
                              ),
                            ),
                    ),

                    Gap(8.h),

                    // ── Hint ──
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        context.tr(widget.hintKey ?? 'phone_verification_hint'),
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                    ),

                    Gap(40.h),

                    // ── Phone Input ──
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
                          onSelected: (c) =>
                              context.read<PhoneEditCubit>().updateCountry(c),
                        ),
                        onPhoneChanged: (v) =>
                            context.read<PhoneEditCubit>().updatePhoneNumber(v),
                      ),
                    ),

                    // ── OTP Method Selector ──
                    if (widget.showMethodSelector) ...[
                      Gap(24.h),
                      _OtpMethodSelector(selectedMethod: state.otpMethod),
                    ],

                    const Spacer(),

                    // ── Submit button ──
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
      context.read<PhoneEditCubit>().clearMessages();

      // capture everything we need before the async gap
      final fullPhone = state.fullPhoneNumber;
      final method = state.otpMethod;
      final source = widget.otpSource;
      final cubit = context.read<PhoneEditCubit>();
      final navigator = Navigator.of(context);

      Future.delayed(const Duration(milliseconds: 1200), () async {
        if (!mounted) return;
        final result = await navigator.push<bool>(
          MaterialPageRoute(
            builder: (_) => UnifiedOtpScreen(
              phoneNumber: fullPhone,
              isPhoneUpdate: source == OtpSource.editPhone,
              otpSource: source,
              otpMethod: method,
            ),
          ),
        );
        if (!mounted) return;
        if (result == true) {
          navigator.pop(true);
        } else {
          cubit.resetError();
        }
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Method Selector (SMS vs WhatsApp)
// ─────────────────────────────────────────────────────────────────────────────

class _OtpMethodSelector extends StatelessWidget {
  final String selectedMethod;
  const _OtpMethodSelector({required this.selectedMethod});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('otp_receive_via'),
            style: Styles.textStyle14.copyWith(color: AppColors.primary800),
          ),
          Gap(8.h),
          Row(
            children: [
              _MethodTile(
                icon: Icons.chat_bubble_outline,
                label: 'WhatsApp',
                value: 'whatsapp',
                selected: selectedMethod == 'whatsapp',
                color: const Color(0xFF25D366),
              ),
              Gap(12.w),
              _MethodTile(
                icon: Icons.sms_outlined,
                label: 'SMS',
                value: 'sms',
                selected: selectedMethod == 'sms',
                color: AppColors.kprimaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final Color color;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<PhoneEditCubit>().selectOtpMethod(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: selected ? color : const Color(0xFFE0E0E0),
              width: selected ? 1.8 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : Colors.grey, size: 18),
              Gap(6.w),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
