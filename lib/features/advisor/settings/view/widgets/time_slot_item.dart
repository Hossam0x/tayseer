import 'package:intl/intl.dart';
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

class _TimeSlotItemState extends State<TimeSlotItem> {
  // 24h internal values for API
  late String _from24h;
  late String _to24h;

  @override
  void initState() {
    super.initState();
    _from24h = widget.initialFrom;
    _to24h = widget.initialTo;
  }

  @override
  void didUpdateWidget(covariant TimeSlotItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFrom != widget.initialFrom) {
      _from24h = widget.initialFrom;
    }
    if (oldWidget.initialTo != widget.initialTo) {
      _to24h = widget.initialTo;
    }
  }

  /// Converts a 24h string like "14:30" → TimeOfDay(14, 30)
  TimeOfDay _parseTime24(String time24) {
    final parts = time24.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  /// Formats a 24h string to a localised 12h display string: "09:00 AM"
  String _format12h(String time24) {
    final tod = _parseTime24(time24);
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final locale = isArabic ? 'ar' : 'en';
    return DateFormat('hh:mm a', locale).format(dt);
  }

  Future<void> _pickTime(bool isFrom) async {
    final initial = _parseTime24(isFrom ? _from24h : _to24h);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isFrom) {
          _from24h = formatted;
        } else {
          _to24h = formatted;
        }
      });
      widget.onTimeChanged?.call(_from24h, _to24h);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          /// Switch Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr(widget.name), style: Styles.textStyle18),
              Switch(
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
            ],
          ),

          /// Animated time range fields
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: widget.initialStatus
                ? Column(
                    children: [
                      SizedBox(height: context.responsiveHeight(5)),
                      _TimeRangeFields(
                        from24h: _from24h,
                        to24h: _to24h,
                        format12h: _format12h,
                        onFromTap: () => _pickTime(true),
                        onToTap: () => _pickTime(false),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Time range row: "From [field]  To [field]"
// ─────────────────────────────────────────────
class _TimeRangeFields extends StatelessWidget {
  final String from24h;
  final String to24h;
  final String Function(String) format12h;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _TimeRangeFields({
    required this.from24h,
    required this.to24h,
    required this.format12h,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text(context.tr('from'), style: Styles.textStyle16),
            _TimeField(value: format12h(from24h), onTap: onFromTap),
          ],
        ),
        Row(
          children: [
            Text(context.tr('to'), style: Styles.textStyle16),
            _TimeField(value: format12h(to24h), onTap: onToTap),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Single tappable time chip
// ─────────────────────────────────────────────
class _TimeField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _TimeField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(10),
          vertical: context.responsiveHeight(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: HexColor('fcffff'),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            width: 2,
            color: HexColor('eb7a91').withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: HexColor('eb7a91').withOpacity(0.5),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 1.5,
              height: context.height * 0.04,
              color: Colors.grey.withOpacity(0.3),
            ),
            Text(
              value,
              style: Styles.textStyle14.copyWith(
                color: HexColor('eb7a91').withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
