import 'package:flutter/services.dart';
import 'package:tayseer/my_import.dart';

class SessionPriceItem extends StatefulWidget {
  final String duration;
  final String initialPrice;
  final bool initialStatus;
  final String currency;
  final bool isPackage;
  final int? initialNumberOfSessions;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<bool>? onStatusChanged;
  final ValueChanged<int?>? onNumberOfSessionsChanged;

  const SessionPriceItem({
    super.key,
    required this.duration,
    required this.initialPrice,
    required this.initialStatus,
    this.currency = 'SAR',
    this.isPackage = false,
    this.initialNumberOfSessions,
    this.onPriceChanged,
    this.onStatusChanged,
    this.onNumberOfSessionsChanged,
  });

  @override
  State<SessionPriceItem> createState() => _SessionPriceItemState();
}

class _SessionPriceItemState extends State<SessionPriceItem> {
  late TextEditingController priceController;
  late TextEditingController numberOfSessionsController;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.initialPrice == '0' ? '' : widget.initialPrice,
    );
    numberOfSessionsController = TextEditingController(
      text: widget.initialNumberOfSessions?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant SessionPriceItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrice != widget.initialPrice) {
      if (priceController.text != widget.initialPrice &&
          (priceController.text.isNotEmpty || widget.initialPrice != '0')) {
        priceController.text = widget.initialPrice;
      }
    }
    if (oldWidget.initialNumberOfSessions != widget.initialNumberOfSessions) {
      final newVal = widget.initialNumberOfSessions?.toString() ?? '';
      if (numberOfSessionsController.text != newVal) {
        numberOfSessionsController.text = newVal;
      }
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    numberOfSessionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double appFeePercentage = 0.50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // السطر العلوي: المدة والتبديل (Switch)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr(widget.duration), style: Styles.textStyle18),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: widget.initialStatus,
                onChanged: widget.onStatusChanged,
                activeTrackColor: AppColors.kprimaryColor,
                inactiveTrackColor: HexColor('b3b3b3'),
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                trackOutlineWidth: const WidgetStatePropertyAll(0),
              ),
            ),
          ],
        ),

        // الجزء المخفي (السعر والحسبة) مع الانيميشن
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- (أ) حقل إدخال السعر ---
                Row(
                  children: [
                    Text(
                      context.tr('session_price'),
                      style: Styles.textStyle14,
                    ),
                    Gap(context.responsiveWidth(8)),
                    Expanded(
                      child: SizedBox(
                        height: context.height * 0.08,
                        child: CustomTextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: widget.onPriceChanged,
                          isNumber: true,
                          controller: priceController,
                          hintText: '0',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          validator: (v) {
                            if (v?.trim().isEmpty ?? true) {
                              return context.tr('field_required');
                            }
                            return null;
                          },
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppImage(
                              AssetsData.kWalletIcon,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr(
                                  'currency_${widget.currency.toLowerCase()}',
                                ),
                                style: Styles.textStyle14Bold.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.isPackage) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      context.tr('select_session_package'),
                      style: Styles.textStyle18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kscandryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      context.tr('share_availability_hint'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        context.tr('number_of_sessions'),
                        style: Styles.textStyle14,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextFormField(
                          controller: numberOfSessionsController,
                          hintText: '0',
                          isNumber: true,
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (v) => widget.onNumberOfSessionsChanged
                              ?.call(int.tryParse(v)),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // --- (ب) نص التنبيه بنسبة الخصم ---
                Center(
                  child: Text(
                    context.tr('app_fees_deduction_note'),
                    style: Styles.textStyle10.copyWith(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 8),

                // --- (ج) بوكس السعر النهائي (الحسبة) ---
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: priceController,
                  builder: (context, value, child) {
                    double price = double.tryParse(value.text) ?? 0;
                    double finalPrice = price * (1 - appFeePercentage);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.kWhiteColor, HexColor('fbf4f8')],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.kprimaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('final_price_after_discount'),
                            style: Styles.textStyle14.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$finalPrice ${context.tr('currency_${widget.currency.toLowerCase()}')}',
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.kprimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          crossFadeState: widget.initialStatus
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}
