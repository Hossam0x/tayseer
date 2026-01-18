import 'package:flutter/cupertino.dart';
import 'package:tayseer/my_import.dart';

class SessionPriceItem extends StatefulWidget {
  final String duration;
  final String initialPrice;
  final bool initialStatus;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<bool>? onStatusChanged;

  const SessionPriceItem({
    super.key,
    required this.duration,
    required this.initialPrice,
    required this.initialStatus,
    this.onPriceChanged,
    this.onStatusChanged,
  });

  @override
  State<SessionPriceItem> createState() => _SessionPriceItemState();
}

class _SessionPriceItemState extends State<SessionPriceItem> {
  late bool isActive;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    isActive = widget.initialStatus;
    priceController = TextEditingController(text: widget.initialPrice);
  }

  @override
  void didUpdateWidget(covariant SessionPriceItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrice != widget.initialPrice) {
      priceController.text = widget.initialPrice;
    }
    if (oldWidget.initialStatus != widget.initialStatus) {
      isActive = widget.initialStatus;
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // السطر العلوي: المدة والتبديل (Switch)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.duration,
              style: Styles.textStyle20.copyWith(color: AppColors.primaryText),
            ),
            Transform.scale(
              scaleX: 0.9,
              scaleY: -0.9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

                  return Transform.scale(
                    scale: scaleFactor,
                    child: CupertinoSwitch(
                      value: isActive,
                      onChanged: (val) {
                        setState(() => isActive = val);
                        widget.onStatusChanged?.call(val);
                      },
                      activeColor: const Color(0xFFF06C88),
                      trackColor: AppColors.inactiveColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Gap(8.h),
        Row(
          children: [
            Text(
              'سعر الجلسة',
              style: Styles.textStyle16.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Gap(8.w),
            Expanded(
              child: Container(
                height: 55.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.secondary200.withOpacity(0.5),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    AppImage(AssetsData.moneyTimesIcon),
                    Gap(8.w),
                    VerticalDivider(
                      indent: 15.h,
                      endIndent: 15.h,
                      width: 1.w,
                      color: AppColors.secondary200.withOpacity(0.5),
                    ),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          widget.onPriceChanged?.call(value);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: Styles.textStyle16.copyWith(
                            color: AppColors.primaryText,
                          ),
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ر.س',
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
