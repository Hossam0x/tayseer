import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/withdraw_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/withdraw_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/my_import.dart';

class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<WithdrawCubit>()..fetchWithdrawMethods(),
        ),
        BlocProvider(create: (_) => getIt<WalletCubit>()..getWallet()),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.kScaffoldColor,
          body: AdvisorBackground(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 105.h,
                  child: Image.asset(
                    AssetsData.homeBarBackgroundImage,
                    fit: BoxFit.fill,
                  ),
                ),
                SafeArea(
                  child: BlocListener<WalletCubit, WalletState>(
                    listenWhen: (prev, curr) =>
                        prev.walletData != curr.walletData,
                    listener: (context, walletState) {
                      if (walletState.walletData != null) {
                        context.read<WithdrawCubit>().syncWallet(
                          balance: walletState.walletData!.balance,
                          currency: walletState.walletData!.currency,
                        );
                      }
                    },
                    child: BlocListener<WithdrawCubit, WithdrawState>(
                      listenWhen: (prev, curr) => prev.method != curr.method,
                      listener: (context, state) {
                        // Clear phone field when switching methods
                        _phoneController.clear();
                        _countryCodeController.text = '+966';
                      },
                      child: Column(
                        children: [
                          Gap(16.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: SimpleAppBar(title: context.tr('withdraw')),
                          ),
                          Gap(16.h),
                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: BlocBuilder<WithdrawCubit, WithdrawState>(
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Current Balance
                                      BalanceCard(),
                                      SizedBox(height: 30.h),
                                      // Amount Input
                                      _buildAmountInput(context, state),
                                      SizedBox(height: 10.h),
                                      // Fees Section
                                      _buildFeesSection(context, state),
                                      SizedBox(height: 20.h),
                                      // Withdraw Method
                                      _buildWithdrawMethod(context, state),
                                      SizedBox(height: 24.h),
                                      // Account Details
                                      _buildAccountDetails(state, context),
                                      SizedBox(height: 24.h),
                                      // Notes
                                      _buildNotesSection(context, state),
                                      SizedBox(height: 20.h),
                                      // Submit Button
                                      _buildSubmitButton(context, state),
                                      SizedBox(height: 40.h),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ), // BlocListener<WithdrawCubit> child
                    ), // BlocListener<WithdrawCubit>
                  ), // BlocListener<WalletCubit> child
                ), // BlocListener<WalletCubit>
              ], // Stack children
            ), // Stack
          ), // AdvisorBackground
        ), // Scaffold
      ), // GestureDetector
    );
  }

  // ── Currency helper ───────────────────────────────────────────────────────

  /// Returns the localized currency label, falling back to the raw code.
  String _localCurrency(BuildContext context, String currency) {
    final key = 'currency_$currency';
    final translated = context.tr(key);
    // easy_localization returns the key itself when not found
    return translated == key ? currency : translated;
  }

  Widget _buildAmountInput(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('amount_to_withdraw'),
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.whiteCardBack,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: 16.w),
                child: AppImage(AssetsData.amountIcon, width: 24.w),
              ),
              Expanded(
                child: TextFormField(
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.transactionAmount],
                  style: Styles.textStyle20Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: Styles.textStyle16.copyWith(
                      color: AppColors.inactiveColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),

                    suffixStyle: Styles.textStyle20Bold.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0;
                    context.read<WithdrawCubit>().updateAmount(amount);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 16.w),
                child: Text(
                  _localCurrency(context, state.walletCurrency),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeesSection(BuildContext context, WithdrawState state) {
    final feeLabel = state.feePercentage > 0
        ? '${state.feePercentage.toStringAsFixed(state.feePercentage % 1 == 0 ? 0 : 1)}%'
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: Text(
            context.tr('withdraw_fees_note'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: AppColors.whiteCardBack,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color.fromRGBO(133, 20, 43, 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('after_app_commission'),
                style: Styles.textStyle16.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Row(
                children: [
                  if (state.feePercentage > 0)
                    Text(
                      '($feeLabel) ',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  GradientText(
                    text: state.amount > 0
                        ? '${state.netAmount.toStringAsFixed(2)} ${_localCurrency(context, state.walletCurrency)}'
                        : '- ${_localCurrency(context, state.walletCurrency)}',
                    style: Styles.textStyle20Bold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawMethod(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('withdraw_method'),
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 8.h),
        if (state.methodsStatus == WithdrawMethodsStatus.loading)
          const Center(child: CircularProgressIndicator())
        else if (state.methodsStatus == WithdrawMethodsStatus.error)
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  context.read<WithdrawCubit>().fetchWithdrawMethods(),
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('retry')),
            ),
          )
        else
          ...state.availableMethods.map(
            (method) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildMethodOption(
                context,
                title: _methodLabel(context, method),
                icon: _methodIcon(method),
                isSelected: state.method == method,
                isImageAsset: _isImageAsset(method),
                onTap: () => context.read<WithdrawCubit>().changeMethod(method),
              ),
            ),
          ),
      ],
    );
  }

  String _methodLabel(BuildContext context, WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.bankAccount:
        return context.tr('bank_account');
      case WithdrawMethod.stcPay:
        return 'STC Pay';
      case WithdrawMethod.urPay:
        return 'UR Pay';
      case WithdrawMethod.instaPay:
        return 'Insta Pay';
      case WithdrawMethod.vodafoneCash:
        return context.tr('vodafone_cash');
      case WithdrawMethod.etisalatCash:
        return 'Etisalat Cash';
      case WithdrawMethod.orangeCash:
        return 'Orange Cash';
    }
  }

  String _methodIcon(WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.bankAccount:
        return AssetsData.icBank;
      case WithdrawMethod.stcPay:
        return AssetsData.stcPay;
      case WithdrawMethod.urPay:
        return AssetsData.phoneIcon; // placeholder — replace when asset added
      case WithdrawMethod.instaPay:
        return AssetsData.instaPay;
      case WithdrawMethod.vodafoneCash:
        return AssetsData.vodafoneCash;
      case WithdrawMethod.etisalatCash:
        return AssetsData.phoneIcon; // placeholder — replace when asset added
      case WithdrawMethod.orangeCash:
        return AssetsData.phoneIcon; // placeholder — replace when asset added
    }
  }

  bool _isImageAsset(WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.instaPay:
      case WithdrawMethod.vodafoneCash:
        return true;
      default:
        return false;
    }
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isImageAsset = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.whiteCardBack,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            icon == AssetsData.icBank
                ? AppImage(icon, width: 22.w, color: AppColors.primary400)
                : AppImage(
                    icon,
                    width: isImageAsset
                        ? (icon == AssetsData.vodafoneCash ? 20.w : 40.w)
                        : 22.w,
                  ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetails(WithdrawState state, BuildContext context) {
    if (state.method == null) return const SizedBox.shrink();

    return state.isBank
        ? _buildBankFields(context, state)
        : _buildPhoneField(context, state);
  }

  Widget _buildBankFields(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('bank_account_details'),
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          context: context,
          icon: AssetsData.icBank,
          isSvg: true,
          hint: context.tr('iban_hint'),
          initialValue: state.iban,
          onChanged: (v) => context.read<WithdrawCubit>().updateIban(v),
        ),
        SizedBox(height: 10.h),
        _buildTextField(
          context: context,
          icon: AssetsData.icBank,
          isSvg: true,
          hint: context.tr('account_holder_name_hint'),
          initialValue: state.accountHolderName,
          onChanged: (v) =>
              context.read<WithdrawCubit>().updateAccountHolderName(v),
        ),
        SizedBox(height: 10.h),
        _buildTextField(
          context: context,
          icon: AssetsData.icBank,
          isSvg: true,
          hint: context.tr('bank_name_hint'),
          initialValue: state.bankName,
          onChanged: (v) => context.read<WithdrawCubit>().updateBankName(v),
        ),
        SizedBox(height: 24.h),
        _buildImageUploadSection(context, state),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('phone_number_label'),
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          isPhoneWithCountryCode: true,
          controller: _phoneController,
          countryCodeController: _countryCodeController,
          onChanged: (value) {
            final fullPhone = '${_countryCodeController.text}$value';
            context.read<WithdrawCubit>().updatePhone(fullPhone);
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String icon,
    required String hint,
    required ValueChanged<String> onChanged,
    String initialValue = '',
    bool isSvg = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.whiteCardBack,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 20.w, color: AppColors.primary300),
          Gap(10.w),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              keyboardType: keyboardType,
              style: Styles.textStyle14.copyWith(color: AppColors.primaryText),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.inactiveColor,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // مستطيل رفع الصور
        GestureDetector(
          onTap: () => context.read<WithdrawCubit>().pickImagesFromGallery(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 16.h),
            // height: 160.h,
            decoration: BoxDecoration(
              color: AppColors.whiteCardBack,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary100),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(AssetsData.uplaodCertificate, width: 35.w),
                  Gap(12.h),
                  Text(
                    textAlign: TextAlign.center,
                    context.tr('upload_id_image_note'),
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.mentionBlue,
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    'PNG, JPG, GIF UP TO 5 MB',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // عرض الصور المرفوعة
        if (state.images.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: List.generate(state.images.length, (index) {
              return Container(
                width: 180.w,
                height: 130.h,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.mainColor),
                ),
                child: _buildImagePreview(context, state.images[index], index),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, File image, int index) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 148.w,
            height: 110.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.mainColor),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 18,
          child: GestureDetector(
            onTap: () => context.read<WithdrawCubit>().removeImage(index),
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.close, size: 20.r, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, WithdrawState state) {
    final currency = _localCurrency(context, state.walletCurrency);
    final hasEnoughBalance =
        state.walletBalance >= WithdrawState.minWithdrawAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!hasEnoughBalance)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: AppColors.error100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              context.tr(
                'insufficient_balance_for_withdraw',
                args: [
                  '${WithdrawState.minWithdrawAmount.toStringAsFixed(0)} $currency',
                ],
              ),
              style: Styles.textStyle14.copyWith(color: AppColors.error600),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          context.tr(
            'min_withdraw_amount',
            args: [
              '${WithdrawState.minWithdrawAmount.toStringAsFixed(0)} $currency',
            ],
          ),
          style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 8.h),
        Text(
          context.tr('transfer_time_note'),
          style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, WithdrawState state) {
    return BlocConsumer<WithdrawCubit, WithdrawState>(
      listenWhen: (prev, curr) =>
          curr.lastWithdrawResult != null && prev.lastWithdrawResult == null ||
          curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.lastWithdrawResult != null) {
          _showWithdrawResultDialog(context, state.lastWithdrawResult!);
        }
        if (state.errorMessage != null &&
            state.methodsStatus != WithdrawMethodsStatus.error) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: CustomBotton(
            height: 54.h,
            width: double.infinity,
            title: state.isLoading
                ? context.tr('requesting_status')
                : context.tr('withdraw'),
            onPressed: state.isLoading || !state.canSubmit
                ? null
                : () => context.read<WithdrawCubit>().submitWithdraw(),
            useGradient: true,
            isLoading: state.isLoading,
          ),
        );
      },
    );
  }

  void _showWithdrawResultDialog(BuildContext context, WithdrawModel result) {
    final isPending = result.status == WithdrawStatus.pending;
    final isCompleted = result.status == WithdrawStatus.completed;

    final statusColor = isPending
        ? AppColors.pendingColor
        : isCompleted
        ? AppColors.success500
        : AppColors.error500;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.12),
                ),
                child: Icon(
                  isPending
                      ? Icons.hourglass_top_rounded
                      : isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  size: 38.r,
                  color: statusColor,
                ),
              ),
              SizedBox(height: 20.h),
              // Title
              Text(
                isPending
                    ? context.tr('withdraw_pending_title')
                    : isCompleted
                    ? context.tr('withdraw_success_title')
                    : context.tr('withdraw_failed_title'),
                style: Styles.textStyle18Bold.copyWith(
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              // Subtitle
              Text(
                isPending
                    ? context.tr('withdraw_pending_message')
                    : isCompleted
                    ? context.tr('withdraw_success_message')
                    : context.tr('withdraw_failed_message'),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // Amount
              Text(
                '${result.amount.toStringAsFixed(2)} ${_localCurrency(context, result.currency)}',
                style: Styles.textStyle20Bold.copyWith(color: statusColor),
              ),
              SizedBox(height: 24.h),
              // Done button
              CustomBotton(
                height: 50.h,
                width: double.infinity,
                title: context.tr('done'),
                onPressed: () {
                  context.read<WithdrawCubit>().clearResult();
                  Navigator.of(context)
                    ..pop() // close dialog
                    ..pop(); // go back to wallet
                },
                useGradient: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
