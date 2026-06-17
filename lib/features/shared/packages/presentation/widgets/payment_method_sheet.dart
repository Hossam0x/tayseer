import 'package:flutter/services.dart';
import 'package:tayseer/core/services/paymob_config_service.dart';
import 'package:tayseer/my_import.dart';

// ─── Public entry point ────────────────────────────────────────────────────────

/// Shows a bottom sheet that asks the user to choose a payment method.
///
/// Fetches fresh Paymob status before showing. If [paymobActive] comes back
/// true, both Paymob and IAP options are shown with a title. Otherwise only
/// the IAP option is shown with no title.
///
/// [onInAppPurchase]   — called when the user picks the IAP option.
/// [onPaymobSelected]  — called with (firstName, lastName, phone) after the
///                       user completes the name + phone collection steps.
Future<void> showPaymentMethodSheet(
  BuildContext context, {
  required VoidCallback onInAppPurchase,
  required void Function(String firstName, String lastName, String phone)
  onPaymobSelected,
}) async {
  final service = getIt<PaymobConfigService>();
  await service.fetchAndUpdateStatus();
  final paymobActive = service.isPaymobActive;

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentMethodSheet(
      onInAppPurchase: onInAppPurchase,
      onPaymobSelected: onPaymobSelected,
      paymobActive: paymobActive,
    ),
  );
}

// ─── Internal sheet widget ─────────────────────────────────────────────────────

class _PaymentMethodSheet extends StatefulWidget {
  final VoidCallback onInAppPurchase;
  final void Function(String firstName, String lastName, String phone)
  onPaymobSelected;
  final bool paymobActive;

  const _PaymentMethodSheet({
    required this.onInAppPurchase,
    required this.onPaymobSelected,
    required this.paymobActive,
  });

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

enum _SheetStep { methodSelection, collectName, collectPhone }

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  _SheetStep _step = _SheetStep.methodSelection;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _nameFocus1 = FocusNode();
  final _nameFocus2 = FocusNode();

  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nameFocus1.dispose();
    _nameFocus2.dispose();
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  bool get _nameValid =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty;

  bool get _phoneValid => _phoneCtrl.text.trim().length >= 10;

  void _onContinueName() {
    if (!_nameValid) return;
    setState(() => _step = _SheetStep.collectPhone);
  }

  void _onContinuePhone() {
    if (!_phoneValid) return;
    Navigator.pop(context);
    widget.onPaymobSelected(
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
      '+20${_phoneCtrl.text.trim()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _buildStep(context),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _SheetStep.methodSelection:
        return _buildMethodSelection(context);
      case _SheetStep.collectName:
        return _buildCollectName(context);
      case _SheetStep.collectPhone:
        return _buildCollectPhone(context);
    }
  }

  // ─── STEP 1: Method selection ────────────────────────────────────────────────

  Widget _buildMethodSelection(BuildContext context) {
    return Container(
      key: const ValueKey('method'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          if (widget.paymobActive) ...[
            Gap(20.h),
            Text(
              context.tr('choose_payment_method'),
              style: Styles.textStyle20Meduim.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kscandryTextColor,
              ),
            ),
          ],
          Gap(24.h),
          if (widget.paymobActive)
            _PaymentOption(
              iconWidget: AppImage(AssetsData.paymob, fit: BoxFit.contain),
              iconColor: const Color(0xFF1A6DD6),
              title: context.tr('paymob'),
              subtitle: context.tr('paymob_subtitle'),
              onTap: () => setState(() => _step = _SheetStep.collectName),
            ),
          _PaymentOption(
            icon: Platform.isIOS ? Icons.apple : null,
            iconWidget: Platform.isIOS
                ? null
                : Padding(
                    padding: EdgeInsets.all(4.0.w),
                    child: AppImage(AssetsData.playStore, fit: BoxFit.cover),
                  ),
            iconColor:
                Platform.isIOS ? Colors.black : const Color(0xFF01875F),
            title: context.tr('in_app_purchase'),
            subtitle: context.tr(
              Platform.isIOS
                  ? 'in_app_purchase_subtitle'
                  : 'google_play_subtitle',
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onInAppPurchase();
            },
          ),
          Gap(8.h),
        ],
      ),
    );
  }

  // ─── STEP 2: Collect First & Last Name ──────────────────────────────────────

  Widget _buildCollectName(BuildContext context) {
    return Padding(
      key: const ValueKey('name'),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _step = _SheetStep.methodSelection),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 20.r,
                    color: AppColors.kscandryTextColor,
                  ),
                ),
                Gap(8.w),
                Text(
                  context.tr('enter_your_name'),
                  style: Styles.textStyle20Meduim.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.kscandryTextColor,
                  ),
                ),
              ],
            ),
            Gap(6.h),
            Text(
              context.tr('name_required_for_payment'),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            ),
            Gap(20.h),
            _buildField(
              controller: _firstNameCtrl,
              focusNode: _nameFocus1,
              label: context.tr('first_name'),
              hint: context.tr('first_name_hint'),
              nextFocus: _nameFocus2,
              textInputAction: TextInputAction.next,
            ),
            Gap(14.h),
            _buildField(
              controller: _lastNameCtrl,
              focusNode: _nameFocus2,
              label: context.tr('last_name'),
              hint: context.tr('last_name_hint'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onContinueName(),
            ),
            Gap(24.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _firstNameCtrl,
              builder: (ctx, a, b) {
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _lastNameCtrl,
                  builder: (ctx2, c, d) {
                    return _ContinueButton(
                      enabled: _nameValid,
                      label: context.tr('continue'),
                      onTap: _onContinueName,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 3: Collect Phone ───────────────────────────────────────────────────

  Widget _buildCollectPhone(BuildContext context) {
    return Padding(
      key: const ValueKey('phone'),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _step = _SheetStep.collectName),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 20.r,
                    color: AppColors.kscandryTextColor,
                  ),
                ),
                Gap(8.w),
                Text(
                  context.tr('enter_your_phone'),
                  style: Styles.textStyle20Meduim.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.kscandryTextColor,
                  ),
                ),
              ],
            ),
            Gap(6.h),
            Text(
              context.tr('phone_required_for_payment'),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            ),
            Gap(20.h),
            _EgyptPhoneField(
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              onSubmitted: (_) => _onContinuePhone(),
            ),
            Gap(24.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _phoneCtrl,
              builder: (ctx, val, child) {
                return _ContinueButton(
                  enabled: _phoneValid,
                  label: context.tr('proceed_to_payment'),
                  onTap: _onContinuePhone,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared field builder ────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    FocusNode? nextFocus,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Styles.textStyle14SemiBold.copyWith(
            color: AppColors.kscandryTextColor,
          ),
        ),
        Gap(6.h),
        TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          keyboardType: TextInputType.name,
          autofocus: false,
          onSubmitted:
              onSubmitted ??
              (_) {
                if (nextFocus != null) {
                  FocusScope.of(context).requestFocus(nextFocus);
                }
              },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Styles.textStyle14.copyWith(
              color: AppColors.secondary300,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Egypt phone field with +20 prefix ─────────────────────────────────────────

class _EgyptPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;

  const _EgyptPhoneField({
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('phone_number'),
          style: Styles.textStyle14SemiBold.copyWith(
            color: AppColors.kscandryTextColor,
          ),
        ),
        Gap(6.h),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofocus: true,
          onSubmitted: onSubmitted,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            prefixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇪🇬', style: TextStyle(fontSize: 18.sp)),
                  Gap(6.w),
                  Text(
                    '+20',
                    style: Styles.textStyle14SemiBold.copyWith(
                      color: AppColors.kscandryTextColor,
                    ),
                  ),
                  Gap(6.w),
                  Container(
                    width: 1,
                    height: 20.h,
                    color: AppColors.secondary200,
                  ),
                ],
              ),
            ),
            hintText: '1xxxxxxxxxx',
            hintStyle: Styles.textStyle14.copyWith(
              color: AppColors.secondary300,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Payment option card ────────────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Widget? iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({
    this.icon,
    this.iconColor,
    this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : assert(icon != null || iconWidget != null);

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.secondary200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: resolvedIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  iconWidget ??
                  Icon(icon, color: resolvedIconColor, size: 35.r),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kscandryTextColor,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    subtitle,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondary400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.r,
              color: AppColors.secondary400,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Continue button ────────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  const _ContinueButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.primary500
              : AppColors.secondary200,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          label,
          style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
