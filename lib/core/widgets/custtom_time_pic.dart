import 'package:tayseer/core/functions/pick_time.dart';
import 'package:tayseer/my_import.dart';

class TimePickerFormField extends FormField<TimeOfDay> {
  TimePickerFormField({
    super.key,
    super.initialValue,
    required String placeholder,
    bool enabled = true,
    super.validator,
    ValueChanged<TimeOfDay?>? onChanged,
  }) : super(
         builder: (FormFieldState<TimeOfDay> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: enabled
                     ? () async {
                         final picked = await pickTime(state.context);
                         if (picked != null) {
                           state.didChange(picked);
                           onChanged?.call(picked);
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
