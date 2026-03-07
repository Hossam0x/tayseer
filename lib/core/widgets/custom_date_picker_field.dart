import 'package:tayseer/core/functions/pac_date.dart';
import 'package:tayseer/my_import.dart';

class DatePickerField extends FormField<DateTime> {
  DatePickerField({
    super.key,
    super.initialValue,
    required String placeholder,
    bool enabled = true,
    bool allowPastDates = true, // ← الإضافة الجديدة
    super.validator,
    ValueChanged<DateTime?>? onDateChanged,
  }) : super(
         builder: (FormFieldState<DateTime> state) {
           // keep FormField state in sync when parent provides a new initialValue
           if (state.widget.initialValue != state.value) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               state.didChange(state.widget.initialValue as DateTime?);
             });
           }
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: enabled
                     ? () async {
                         final picked = await pickDate(
                           state.context,
                           initialDate: state.value ?? DateTime.now(),

                           firstDate: allowPastDates
                               ? DateTime(1900)
                               : DateTime.now(),

                           lastDate: DateTime.now().add(Duration(days: 3650)),
                         );

                         if (picked != null) {
                           state.didChange(picked);
                           onDateChanged?.call(picked);
                         }
                       }
                     : null,
                 child: Container(
                   padding: const EdgeInsets.symmetric(
                     horizontal: 12,
                     vertical: 15,
                   ),
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
                               ? placeholder
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
         },
       );
}
