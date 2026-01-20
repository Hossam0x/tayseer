// import 'package:tayseer/my_import.dart';

// class BoostButton extends StatelessWidget {
//   const BoostButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, AppRouter.kBoostAccountView);
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 100),
//         width: double.infinity,
//         height: 56.h,
//         padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
//         margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: const [
//               Color.fromRGBO(245, 192, 3, 1),
//               Color.fromRGBO(228, 78, 108, 1),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.w),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AppImage(AssetsData.boostIcon),
//             Gap(12.w),
//             Text(
//               'تعزيز',
//               style: Styles.textStyle20SemiBold.copyWith(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
