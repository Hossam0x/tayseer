// import 'package:tayseer/my_import.dart';

// class ProfileEmptyState extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String message;
//   final String buttonText;
//   final VoidCallback onButtonPressed;

//   const ProfileEmptyState({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.message,
//     required this.buttonText,
//     required this.onButtonPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 32.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80.w,
//               height: 80.w,
//               decoration: BoxDecoration(
//                 color: AppColors.kprimaryColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 40.sp, color: AppColors.kprimaryColor),
//             ),
//             Gap(24.h),
//             Text(
//               title,
//               style: Styles.textStyle16Bold.copyWith(
//                 color: AppColors.blackColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             Gap(8.h),
//             Text(
//               message,
//               style: Styles.textStyle14.copyWith(
//                 color: AppColors.secondary400,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             Gap(32.h),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.kprimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                 ),
//                 onPressed: onButtonPressed,
//                 child: Text(
//                   buttonText,
//                   style: Styles.textStyle14Bold.copyWith(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
