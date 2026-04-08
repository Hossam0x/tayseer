// // lib/features/user/my_space/presentation/widget/reschedule/day_time_row.dart

// import 'package:tayseer/my_import.dart';

// class DayTimeRow extends StatelessWidget {
//   final String dayName;
//   final String dayNumber;
//   final String monthName;
//   final String time;
//   final bool isSelected;
//   final bool isAvailable;
//   final VoidCallback? onTap;

//   const DayTimeRow({
//     super.key,
//     required this.dayName,
//     required this.dayNumber,
//     required this.monthName,
//     required this.time,
//     required this.isSelected,
//     required this.isAvailable,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         margin: EdgeInsets.only(bottom: 2.h),
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//         decoration: BoxDecoration(
//           // ★ خلفية متدرجة عند الاختيار
//           gradient: isSelected
//               ? LinearGradient(
//                   colors: [
//                     AppColors.kprimaryColor.withOpacity(0.18),
//                     AppColors.kprimaryColor.withOpacity(0.05),
//                   ],
//                   begin: isArabic
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
//                 )
//               : null,
//           color: isSelected ? null : Colors.transparent,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // ★ الوقت (يسار)
//             Text(
//               time,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: _getTextColor(),
//               ),
//             ),

//             // ★ اليوم والتاريخ (يمين)
//             Text(
//               '$dayName, $dayNumber $monthName',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: _getTextColor(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getTextColor() {
//     if (!isAvailable) return Colors.grey.shade300;
//     if (isSelected) return AppColors.kprimaryColor;
//     return Colors.black87;
//   }
// }
