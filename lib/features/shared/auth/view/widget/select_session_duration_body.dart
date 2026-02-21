import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class SelectSessionDurationBody extends StatefulWidget {
  const SelectSessionDurationBody({super.key});

  @override
  State<SelectSessionDurationBody> createState() =>
      _SelectSessionDurationBodyState();
}

class _SelectSessionDurationBodyState extends State<SelectSessionDurationBody> {
  final TextEditingController _price30Controller = TextEditingController();
  final TextEditingController _price60Controller = TextEditingController();

  @override
  void dispose() {
    _price30Controller.dispose();
    _price60Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// Back Button
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),

              Gap(context.responsiveHeight(12)),

              /// Title
              Text(
                context.tr('selectSessionDuration'),
                style: Styles.textStyle20Bold.copyWith(
                  color: AppColors.kscandryTextColor,
                ),
              ),

              Gap(context.responsiveHeight(6)),

              /// Hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  context.tr('selectSessionDurationHint'),
                  textAlign: TextAlign.center,
                  style: Styles.textStyle12,
                ),
              ),

              Gap(context.responsiveHeight(24)),

              /// Duration Options List
              Expanded(
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    // ممكن هنا نضيف logic لو عاوزين
                  },
                  builder: (context, state) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // --- خيار 30 دقيقة ---
                        _SessionDurationItem(
                          title: context.tr('thirtyMinutes'),
                          isActive: state.isThirtyMinutesSelected,
                          priceController: _price30Controller,
                          onSwitchChanged: (value) {
                            authCubit.toggle30Minutes(value);
                            if (!value) _price30Controller.clear();
                          },
                          onPriceChanged: (value) {
                            authCubit.set30MinPrice(value);
                          },
                        ),

                        Gap(context.responsiveHeight(16)),

                        // --- خيار 60 دقيقة ---
                        _SessionDurationItem(
                          title: context.tr('sixtyMinutes'),
                          isActive: state.isSixtyMinutesSelected,
                          priceController: _price60Controller,
                          onSwitchChanged: (value) {
                            authCubit.toggle60Minutes(value);
                            if (!value) _price60Controller.clear();
                          },
                          onPriceChanged: (value) {
                            authCubit.set60MinPrice(value);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// Next Button
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state.addServiceProviderState == CubitStates.success) {
                    context.pushNamed(AppRouter.kAccountReviewScreen);
                  } else if (state.addServiceProviderState ==
                      CubitStates.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        isError: true,
                        text: state.errorMessage ?? '',
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final bool is30Valid =
                      state.isThirtyMinutesSelected &&
                      state.price30Min.isNotEmpty;
                  final bool is60Valid =
                      state.isSixtyMinutesSelected &&
                      state.price60Min.isNotEmpty;

                  final hasSelection = is30Valid || is60Valid;

                  return CustomBotton(
                    width: context.width * .9,
                    title: state.addServiceProviderState == CubitStates.loading
                        ? context.tr('sending')
                        : context.tr('next'),
                    useGradient: hasSelection,
                    backGroundcolor: AppColors.kgreyColor,
                    onPressed: hasSelection
                        ? () {
                            authCubit.addServiceProvider();
                          }
                        : null,
                  );
                },
              ),

              Gap(context.responsiveHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionDurationItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function(bool) onSwitchChanged;
  final Function(String) onPriceChanged;
  final TextEditingController priceController;

  const _SessionDurationItem({
    required this.title,
    required this.isActive,
    required this.onSwitchChanged,
    required this.onPriceChanged,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    // نسبة الخصم (مثلاً 50%)
    const double appFeePercentage = 0.50;

    return Column(
      children: [
        /// 1. العنوان والسويتش
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Styles.textStyle18),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isActive,
                onChanged: onSwitchChanged,
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

        /// 2. الجزء المخفي (السعر والحسبة)
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
                          onChanged: onPriceChanged,
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
                                CurrencyHelper.getCurrencySymbolFromContext(
                                  context,
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

                const SizedBox(height: 8),

                // --- (ب) نص التنبيه بنسبة الخصم ---
                Center(
                  child: Text(
                    // "سيتم خصم 50% من سعر الجلسة الواحدة رسوم للتطبيق"
                    context.tr('app_fees_deduction_note'),
                    style: Styles.textStyle10.copyWith(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 8),

                // --- (ج) بوكس السعر النهائي (الحسبة) ---
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: priceController,
                  builder: (context, value, child) {
                    // منطق الحسبة
                    double price = double.tryParse(value.text) ?? 0;
                    double finalPrice =
                        price * (1 - appFeePercentage); // السعر بعد الخصم
                    // أو لو المعادلة هي إن ده ربحك: double finalPrice = price * 0.5;

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
                            CurrencyHelper.formatPriceFromContext(
                              context,
                              finalPrice,
                            ),
                            style: Styles.textStyle16.copyWith(
                              color: AppColors
                                  .kprimaryColor, // اللون الأحمر/الوردي
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
          crossFadeState: isActive
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}
