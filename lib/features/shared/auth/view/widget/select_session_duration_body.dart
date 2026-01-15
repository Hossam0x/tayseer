import 'package:tayseer/features/shared/auth/view/widget/session_dutration_item.dart';
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
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),

              Gap(context.responsiveHeight(12)),

              /// Title
              Text(
                context.tr('selectSessionDuration'),
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.bold,
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
                        SessionDurationItem(
                          title: context.tr('30_minutes'),
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
                        SessionDurationItem(
                          title: context.tr('60_minutes'),
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
                    context.pushNamed(AppRouter.kActivationSuccessView);
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

// class _SessionDurationItem extends StatelessWidget {
//   final String title;
//   final bool isActive;
//   final Function(bool) onSwitchChanged;
//   final Function(String) onPriceChanged;
//   final TextEditingController priceController;

//   const _SessionDurationItem({
//     required this.title,
//     required this.isActive,
//     required this.onSwitchChanged,
//     required this.onPriceChanged,
//     required this.priceController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(title, style: Styles.textStyle18),
//             Transform.scale(
//               scale: 0.8, // تصغير بسيط عشان يناسب التصميم
//               child: Switch(
//                 value: isActive,
//                 onChanged: onSwitchChanged,
//                 activeTrackColor: AppColors.kprimaryColor,
//                 inactiveTrackColor: HexColor('b3b3b3'),
//                 activeColor: Colors.white,
//                 inactiveThumbColor: Colors.white,
//                 trackOutlineColor: const WidgetStatePropertyAll(
//                   Colors.transparent,
//                 ),
//                 trackOutlineWidth: const WidgetStatePropertyAll(0),
//               ),
//             ),
//           ],
//         ),

        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Row(
              children: [
                Text(context.tr('session_price'), style: Styles.textStyle14),
                Gap(context.responsiveWidth(8)),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: CustomTextFormField(
                      isNumber: true,
                      controller: priceController,
                      hintText: '0',
                      prefixIcon: AppImage(
                        AssetsData.kWalletIcon,
                        width: 5,
                        height: 5,
                        fit: BoxFit.contain,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('currency_rs'),
                            style: Styles.textStyle14Bold.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
//  TextField(
//                       controller: priceController,
//                       keyboardType: TextInputType.number,
//                       onChanged: onPriceChanged,
//                       textAlign: TextAlign.start,
//                       decoration: InputDecoration(
//                         fillColor: AppColors.kWhiteColor,
//                         hintText: '0',
//                         hintStyle: Styles.textStyle14.copyWith(
//                           color: AppColors.kgreyColor,
//                         ),
//                         suffixText: context.tr('currency_rs'),
//                         suffixStyle: Styles.textStyle14.copyWith(
//                           color: AppColors.kgreyColor,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.grey),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: Colors.grey.withOpacity(0.3),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: AppColors.kprimaryColor,
//                           ),
//                         ),

//                         prefixIcon: AppImage(
//                           AssetsData.kWalletIcon,
//                           width: 10,
//                           height: 10,
//                         ),
//                       ),
//                     ),
