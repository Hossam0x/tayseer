// import 'package:tayseer/my_import.dart';

// /// Note تظهر فقط على Android قبل الدفع بـ Paymob.
// /// تخبر المستخدم بكيفية تفعيل/إلغاء الـ Auto-Renew من داخل بوابة الدفع.
// class SaveCardNote extends StatelessWidget {
//   const SaveCardNote({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.white30),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline_rounded, color: Colors.white70, size: 18.w),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.white.withOpacity(0.85),
//                   height: 1.5,
//                 ),
//                 children: [
//                   TextSpan(text: context.tr('save_card_note_enable')),
//                   TextSpan(
//                     text: ' ${context.tr('save_card_note_option')} ',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                   TextSpan(text: context.tr('save_card_note_enable_suffix')),
//                   TextSpan(text: context.tr('save_card_note_disable')),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
