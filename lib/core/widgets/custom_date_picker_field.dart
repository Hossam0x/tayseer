import 'package:tayseer/core/functions/pac_date.dart';
import 'package:tayseer/my_import.dart';

class DatePickerField extends FormField<DateTime> {
  DatePickerField({
    super.key,
    super.initialValue,
    required String placeholder,
    bool enabled = true,
    bool allowPastDates = true,
    super.validator,
    ValueChanged<DateTime?>? onDateChanged,
  }) : super(
         builder: (FormFieldState<DateTime> state) {
           return _DatePickerFieldContent(
             state: state,
             placeholder: placeholder,
             enabled: enabled,
             allowPastDates: allowPastDates,
             onDateChanged: onDateChanged,
           );
         },
       );
}

class _DatePickerFieldContent extends StatefulWidget {
  const _DatePickerFieldContent({
    required this.state,
    required this.placeholder,
    required this.enabled,
    required this.allowPastDates,
    this.onDateChanged,
  });

  final FormFieldState<DateTime> state;
  final String placeholder;
  final bool enabled;
  final bool allowPastDates;
  final ValueChanged<DateTime?>? onDateChanged;

  @override
  State<_DatePickerFieldContent> createState() =>
      _DatePickerFieldContentState();
}

class _DatePickerFieldContentState extends State<_DatePickerFieldContent> {
  @override
  void didUpdateWidget(_DatePickerFieldContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newInitial = widget.state.widget.initialValue;
    if (newInitial != widget.state.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.state.didChange(newInitial);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await pickDate(
      context,
      initialDate: widget.state.value ?? DateTime.now(),
      firstDate: widget.allowPastDates ? DateTime(1900) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null && mounted) {
      widget.state.didChange(picked);
      widget.onDateChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.enabled ? _pickDate : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: state.hasError
                    ? Colors.red
                    : AppColors.kprimaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.kprimaryColor.withOpacity(0.3),
                ),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    width: 10,
                    thickness: 1.5,
                    color: AppColors.kprimaryColor.withOpacity(0.3),
                  ),
                ),
                Expanded(
                  child: Text(
                    state.value == null
                        ? widget.placeholder
                        : '${state.value!.day}/${state.value!.month}/${state.value!.year}',
                    style: Styles.textStyle12.copyWith(
                      color: state.value == null
                          ? AppColors.kprimaryColor.withOpacity(0.5)
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.hasError) ...[
          const SizedBox(height: 6),
          Text(
            state.errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ],
    );
  }
}
