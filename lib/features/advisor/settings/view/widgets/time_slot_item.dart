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
  late TextEditingController fromController;
  late TextEditingController toController;
  late AnimationController _animationController;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    _from24h = widget.initialFrom;
    _to24h = widget.initialTo;
    fromController = TextEditingController(
      text: _formatTo12Hour(widget.initialFrom),
    );
    toController = TextEditingController(
      text: _formatTo12Hour(widget.initialTo),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    heightAnimation = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.initialStatus) {
      _animationController.forward();
    } else {
      _animationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant TimeSlotItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFrom != widget.initialFrom) {
      _from24h = widget.initialFrom;
      fromController.text = _formatTo12Hour(widget.initialFrom);
    }
    if (oldWidget.initialTo != widget.initialTo) {
      _to24h = widget.initialTo;
      toController.text = _formatTo12Hour(widget.initialTo);
    }
    if (oldWidget.initialStatus != widget.initialStatus) {
      if (widget.initialStatus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Future<void> _pickTime(bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(isFrom ? fromController.text : toController.text),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Store as 24h internally for API, display as 12h
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (isFrom) {
        fromController.text = _formatTo12Hour(formattedTime);
        _from24h = formattedTime;
      } else {
        toController.text = _formatTo12Hour(formattedTime);
        _to24h = formattedTime;
      }

      widget.onTimeChanged?.call(_from24h, _to24h);
    }
  }

  // 24h internal values for API
  late String _from24h;
  late String _to24h;

  TimeOfDay _parseTime(String time) {
    // Handle both 12h display (e.g. "09:00") and 24h (e.g. "09:00")
    final cleaned = time.replaceAll(RegExp(r'[APM\s]'), '');
    final parts = cleaned.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTo12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
              context.tr(widget.name),
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
                      value: widget.initialStatus,
                      onChanged: (val) {
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

        // الأنيميشن لظهور أو اختفاء حقول الوقت
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Align(
              heightFactor: _animationController.value,
              alignment: Alignment.topCenter,
              child: Opacity(opacity: _animationController.value, child: child),
            );
          },
          child: Column(
            children: [
              Gap(8.h),
              Row(
                children: [
                  Text(
                    context.tr('from'),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(child: _buildTimeField(fromController, true)),
                  Gap(8.w),
                  Text(
                    context.tr('to'),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(child: _buildTimeField(toController, false)),
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
          border: Border.all(color: AppColors.inactiveColor),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.inactiveColor, size: 22.w),
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
