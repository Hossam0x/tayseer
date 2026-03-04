import 'package:tayseer/core/functions/pick_time.dart';
import 'package:tayseer/my_import.dart';

class TimePickerFormField extends FormField<TimeOfDay> {
  TimePickerFormField({
    super.key,
    super.initialValue,
    required String placeholder,
    bool enabled = true,
    bool disablePastTime = false, // ✅ الخاصية الجديدة
    super.validator,
    ValueChanged<TimeOfDay?>? onChanged,
    DateTime? minDateForTime,
  }) : super(
         builder: (FormFieldState<TimeOfDay> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: enabled
                     ? () async {
                         // Determine minDate for the time picker.
                         // If a min date for the event is provided and it is today,
                         // then prevent selecting past times by using `DateTime.now()`.
                         // Otherwise do not restrict time selection.
                         DateTime? minTime;
                         final now = DateTime.now();
                         if (minDateForTime != null) {
                           if (minDateForTime.year == now.year &&
                               minDateForTime.month == now.month &&
                               minDateForTime.day == now.day) {
                             // event date is today -> restrict to current time
                             minTime = now;
                           } else {
                             // event date is in future -> no restriction
                             minTime = null;
                           }
                         } else if (disablePastTime) {
                           // no event date provided but caller asked to disable past times
                           minTime = now;
                         } else {
                           minTime = null;
                         }

                         final result = await pickTime(
                           state.context,
                           minDate: minTime,
                         );

                         // If user cancelled -> do nothing
                         if (result.time == null && !result.wasInvalid) return;

                         // If user picked an invalid (past) time -> clear value so validator fails
                         if (result.wasInvalid) {
                           state.didChange(null);
                           onChanged?.call(null);
                           return;
                         }

                         // Valid pick
                         final picked = result.time!;
                         state.didChange(picked);
                         onChanged?.call(picked);
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
                         Icons.access_time,
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
                               : state.value!.format(state.context),
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
                   style: const TextStyle(color: Colors.red, fontSize: 11),
                 ),
               ],
             ],
           );
         },
       );
}
