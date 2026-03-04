import 'package:tayseer/my_import.dart';

class LocationPickerFormField extends FormField<bool> {
  LocationPickerFormField({
    super.key,
    required Widget child,
    required VoidCallback onTap,
    super.validator,
    bool super.initialValue = false,
  }) : super(
         builder: (state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: () async {
                   onTap();
                   state.didChange(true);
                 },
                 child: Container(
                   padding: EdgeInsets.symmetric(
                     horizontal: 16.w,
                     vertical: 14.h,
                   ),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(12.r),
                     border: Border.all(
                       color: state.hasError
                           ? Colors.red
                           : AppColors.kprimaryColor.withOpacity(0.3),
                       width: 1,
                     ),
                   ),
                   child: child,
                 ),
               ),

               /// رسالة الخطأ
               if (state.hasError) ...[
                 SizedBox(height: 6.h),
                 Text(
                   state.errorText ?? '',
                   style: Styles.textStyle10.copyWith(color: Colors.red),
                 ),
               ],
             ],
           );
         },
       );
}
