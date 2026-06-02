import 'package:tayseer/core/widgets/custom_otp_field.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

/// شاشة OTP موحدة تُستخدم في كل السيناريوهات:
/// - تعديل رقم الهاتف من البروفايل  [OtpSource.editPhone]
/// - تأكيد الإيميل الجديد            [OtpSource.email]
/// - التسجيل / الـ onboarding       [OtpSource.phone]
///
/// الشاشة تعمل مع [OtpCubit] — لو الـ cubit موجود بالفعل في الـ tree
/// ابعت [provideCubit] = false.
/// لو محتاج الشاشة تعمل cubit جديد ابعت [provideCubit] = true
/// مع [phoneNumber] و [otpSource] و [otpMethod].
class UnifiedOtpScreen extends StatelessWidget {
  // ── params لما الشاشة بتعمل الـ cubit بنفسها ──
  final String? phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final OtpSource otpSource;
  final String otpMethod;
  final bool provideCubit;

  const UnifiedOtpScreen({
    super.key,
    this.phoneNumber,
    this.isPhoneUpdate = false,
    this.isEmailUpdate = false,
    this.otpSource = OtpSource.phone,
    this.otpMethod = 'whatsapp',
    this.provideCubit = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomBackground(child: _UnifiedOtpBody()),
    );

    if (!provideCubit) return scaffold;

    return BlocProvider(
      create: (_) => getIt<OtpCubit>(
        param1: OtpCubitParams(
          phoneNumber: phoneNumber ?? '',
          isPhoneUpdate: isPhoneUpdate,
          isEmailUpdate: isEmailUpdate,
          otpSource: otpSource,
          otpMethod: otpMethod,
        ),
      ),
      child: scaffold,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _UnifiedOtpBody extends StatelessWidget {
  const _UnifiedOtpBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          AppToast.error(context, context.tr(state.errorMessage));
          context.read<OtpCubit>().clearMessages();
        } else if (state.successMessage.isNotEmpty &&
            state.otpStatus == OtpStatus.success) {
          AppToast.success(context, context.tr(state.successMessage));
          context.read<OtpCubit>().clearMessages();
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pop(context, true);
              context.read<OtpCubit>().resetError();
            }
          });
        } else if (state.successMessage.isNotEmpty) {
          AppToast.success(context, context.tr(state.successMessage));
          context.read<OtpCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: context.height * 0.02),

                        // ── Back button ──
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 25),
                          child: Align(
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

                        SizedBox(height: context.height * 0.06),

                        // ── Title ──
                        Text(
                          _resolveTitle(context, state),
                          style: Styles.textStyle24.copyWith(
                            color: HexColor('590d1c'),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: context.height * 0.02),

                        // ── Subtitle: "تم إرسال الكود على WhatsApp إلى ..." ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _SentToSubtitle(state: state),
                        ),

                        SizedBox(height: context.height * 0.04),

                        // ── OTP boxes ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomOtpField(
                            onChanged: (v) =>
                                context.read<OtpCubit>().updateOtpCode(v),
                            onCompleted: (_) {
                              if (!state.isLoading) {
                                context.read<OtpCubit>().verifyOtp();
                              }
                            },
                          ),
                        ),

                        SizedBox(height: context.height * 0.04),

                        // ── Resend ──
                        _ResendSection(state: state),

                        SizedBox(height: context.height * 0.03),
                      ],
                    ),
                  ),
                ),

                // ── Confirm button — stays above keyboard ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.width * 0.05,
                    8,
                    context.width * 0.05,
                    24,
                  ),
                  child: CustomBotton(
                    width: double.infinity,
                    useGradient: true,
                    title: state.isLoading
                        ? context.tr('verifying')
                        : context.tr('confirm'),
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (state.otpCode.length == 6) {
                              context.read<OtpCubit>().verifyOtp();
                            } else {
                              AppToast.error(
                                context,
                                context.tr('otp_digit_6_error'),
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveTitle(BuildContext context, OtpState state) {
    if (state.isEmailUpdate) return context.tr('confirm_new_email');
    if (state.isPhoneUpdate) return context.tr('confirm_new_phone');
    return context.tr('otp_title');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtitle: يعرض الرقم مع أول جزء (كود الدولة) والباقي نجوم
// ─────────────────────────────────────────────────────────────────────────────

class _SentToSubtitle extends StatelessWidget {
  final OtpState state;
  const _SentToSubtitle({required this.state});

  /// يعرض الرقم بشكل: +20 *** *** 163
  String _maskPhone(String fullPhone) {
    // استخرج كود الدولة
    final prefixes = [
      '+966',
      '+20',
      '+971',
      '+965',
      '+974',
      '+968',
      '+973',
      '+962',
      '+961',
      '+964',
      '+212',
      '+213',
      '+216',
    ];
    String countryCode = '';
    String local = fullPhone;
    for (final p in prefixes) {
      if (fullPhone.startsWith(p)) {
        countryCode = p;
        local = fullPhone.substring(p.length);
        break;
      }
    }
    // أظهر آخر 3 أرقام فقط، الباقي نجوم
    final visible = local.length >= 3
        ? local.substring(local.length - 3)
        : local;
    final masked = '*' * (local.length - visible.length);
    return '$countryCode $masked$visible';
  }

  @override
  Widget build(BuildContext context) {
    final isWhatsapp = !state.isEmailUpdate;

    final maskedTarget = state.isEmailUpdate
        ? state
              .phoneNumber // للإيميل ما نعمل mask
        : _maskPhone(state.phoneNumber);

    final channelKey = isWhatsapp ? 'sent_via_whatsapp' : 'otp_sent_to_number';

    return Text(
      context.tr(channelKey, args: [maskedTarget]),
      textAlign: TextAlign.center,
      style: Styles.textStyle14.copyWith(color: Colors.grey),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resend Section
// ─────────────────────────────────────────────────────────────────────────────

class _ResendSection extends StatelessWidget {
  final OtpState state;
  const _ResendSection({required this.state});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (state.canResend) {
      return TextButton(
        onPressed: state.isLoading
            ? null
            : () => context.read<OtpCubit>().resendCode(),
        child: Text(
          context.tr('resend_code'),
          style: Styles.textStyle12.copyWith(
            color: HexColor('4d81e7'),
            decoration: TextDecoration.underline,
            decorationColor: HexColor('4d81e7'),
            decorationThickness: 1.5,
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          context.tr('resend_code_in'),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(state.resendSeconds),
          style: Styles.textStyle12.copyWith(color: HexColor('4d81e7')),
        ),
      ],
    );
  }
}
