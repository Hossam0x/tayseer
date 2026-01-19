import 'package:flutter/cupertino.dart';
import 'package:tayseer/my_import.dart';

typedef TimeChangedCallback = void Function(String start, String end);

class TimeSlotItem extends StatefulWidget {
  final String name;
  final String initialFrom;
  final String initialTo;
  final bool initialStatus;
  final ValueChanged<bool>? onStatusChanged;
  final TimeChangedCallback? onTimeChanged;

  const TimeSlotItem({
    super.key,
    required this.name,
    required this.initialFrom,
    required this.initialTo,
    required this.initialStatus,
    this.onStatusChanged,
    this.onTimeChanged,
  });

  @override
  State<TimeSlotItem> createState() => _TimeSlotItemState();
}

class _TimeSlotItemState extends State<TimeSlotItem>
    with SingleTickerProviderStateMixin {
  late bool isActive;
  late TextEditingController fromController;
  late TextEditingController toController;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    isActive = widget.initialStatus;
    fromController = TextEditingController(text: widget.initialFrom);
    toController = TextEditingController(text: widget.initialTo);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // تشغيل أو إيقاف الأنيميشن بناءً على حالة isActive
    if (isActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant TimeSlotItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFrom != widget.initialFrom) {
      fromController.text = widget.initialFrom;
    }
    if (oldWidget.initialTo != widget.initialTo) {
      toController.text = widget.initialTo;
    }
    if (oldWidget.initialStatus != widget.initialStatus) {
      _toggleStatus(widget.initialStatus, animate: false);
    }
  }

  void _toggleStatus(bool val, {bool animate = true}) {
    setState(() => isActive = val);

    if (animate) {
      if (val) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    } else {
      if (val) {
        _animationController.value = 1.0;
      } else {
        _animationController.value = 0.0;
      }
    }

    widget.onStatusChanged?.call(val);
  }

  Future<void> _pickTime(bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(isFrom ? fromController.text : toController.text),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (isFrom) {
          fromController.text = formattedTime;
        } else {
          toController.text = formattedTime;
        }
      });

      // إرسال القيم المحدثة
      widget.onTimeChanged?.call(fromController.text, toController.text);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // السطر العلوي: اليوم والتبديل (Switch)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: Styles.textStyle20.copyWith(color: AppColors.primaryText),
            ),
            Transform.scale(
              scaleX: 0.9,
              scaleY: -0.9,
              child: CupertinoSwitch(
                value: isActive,
                onChanged: (val) {
                  setState(() => isActive = val);
                  widget.onStatusChanged?.call(val);
                },
                activeColor: const Color(0xFFF06C88),
                trackColor: AppColors.inactiveColor,
              ),
            ),
          ],
        ),

        // الأنيميشن لظهور أو اختفاء حقول الوقت
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: SizedBox(
                height: _heightAnimation.value,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: 70,
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            children: [
              Gap(8.h),
              Row(
                children: [
                  Text(
                    'من',
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(child: _buildTimeField(toController, false)),
                  Gap(8.w),
                  Text(
                    'إلى',
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(child: _buildTimeField(fromController, true)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(TextEditingController controller, bool isFrom) {
    return GestureDetector(
      onTap: () => _pickTime(isFrom),
      child: Container(
        height: 55.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.inactiveColor, width: 2.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.inactiveColor),
            Gap(8.w),
            VerticalDivider(
              indent: 15.h,
              endIndent: 15.h,
              width: 1.w,
              color: AppColors.inactiveColor,
            ),
            Gap(8.w),
            Expanded(
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '09:00',
                    hintStyle: Styles.textStyle16.copyWith(
                      color: AppColors.primaryText,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}
