import 'package:tayseer/my_import.dart';

class SessionDurationItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function(bool) onSwitchChanged;
  final Function(String) onPriceChanged;
  final TextEditingController priceController;

  const SessionDurationItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onSwitchChanged,
    required this.onPriceChanged,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Styles.textStyle18),
            Transform.scale(
              scale: 0.8, // تصغير بسيط عشان يناسب التصميم
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
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      onChanged: onPriceChanged,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: Styles.textStyle14.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                        suffixText: context.tr('currency_rs'),
                        suffixStyle: Styles.textStyle14.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.kprimaryColor,
                          ),
                        ),

                        prefixIcon: AppImage(
                          AssetsData.kWalletIcon,
                          width: 24,
                          height: 24,
                        ),
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
