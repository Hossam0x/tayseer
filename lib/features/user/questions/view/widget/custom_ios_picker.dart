// lib/core/widgets/custom_ios_picker.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tayseer/my_import.dart';

class CustomIosPicker extends StatelessWidget {
  /// القيمة المبدئية
  final int initialValue;

  /// أقل قيمة
  final int minValue;

  /// أعلى قيمة
  final int maxValue;

  /// callback عند تغيير القيمة
  final ValueChanged<int> onSelectedItemChanged;

  /// الوحدة (مثل kg, cm) - اختياري
  final String? unit;

  /// اللون الأساسي
  final Color? primaryColor;

  const CustomIosPicker({
    super.key,
    required this.initialValue,
    required this.onSelectedItemChanged,
    this.minValue = 18,
    this.maxValue = 100,
    this.unit,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final values = List.generate(
      maxValue - minValue + 1,
      (index) => index + minValue,
    );
    final initialIndex = (initialValue - minValue).clamp(0, values.length - 1);
    final color = primaryColor ?? HexColor('ff5069');

    return Container(
      height: context.height * 0.4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// الخطوط الملونة
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 2,
                width: unit != null ? 120 : 100,
                color: color,
              ),
              const SizedBox(height: 48),
              Container(
                height: 2,
                width: unit != null ? 120 : 100,
                color: color,
              ),
            ],
          ),

          /// CupertinoPicker
          CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: initialIndex,
            ),
            itemExtent: 50,
            diameterRatio: 1.2,
            squeeze: 1.0,
            useMagnifier: true,
            magnification: 1.3,
            selectionOverlay: const SizedBox.shrink(),
            onSelectedItemChanged: (index) {
              // Haptic feedback للـ Android
              HapticFeedback.selectionClick();
              onSelectedItemChanged(values[index]);
            },
            children: values.map((value) {
              return Center(
                child: unit != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.toString(),
                            style: Styles.textStyle20Bold.copyWith(
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            unit!,
                            style: Styles.textStyle14.copyWith(
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        value.toString(),
                        style: Styles.textStyle20Bold.copyWith(color: color),
                      ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
