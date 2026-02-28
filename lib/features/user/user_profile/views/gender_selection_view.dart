// import 'package:tayseer/core/widgets/simple_app_bar.dart';
// import 'package:tayseer/my_import.dart';

// class GenderSelectionView extends StatefulWidget {
//   final String initialGender;
//   const GenderSelectionView({super.key, this.initialGender = "ذكر"});

//   @override
//   State<GenderSelectionView> createState() => _GenderSelectionViewState();
// }

// class _GenderSelectionViewState extends State<GenderSelectionView> {
//   late String selectedGender;

//   @override
//   void initState() {
//     super.initState();
//     selectedGender = widget.initialGender;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: AdvisorBackground(
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//                 child: SimpleAppBar(title: 'النوع', isLargeTitle: true),
//               ),

//               Gap(80.h),

//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 35.w),
//                 child: Column(
//                   children: [
//                     _buildGenderOption("أنثى"),
//                     Gap(16.h),
//                     _buildGenderOption("ذكر"),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
//                 child: CustomBotton(
//                   height: 53.h,
//                   width: double.infinity,
//                   title: 'تأكيد',
//                   useGradient: true,
//                   onPressed: () {
//                     Navigator.pop(context, selectedGender);
//                   },
//                 ),
//               ),

//               Gap(MediaQuery.of(context).viewInsets.bottom),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGenderOption(String gender) {
//     bool isSelected = selectedGender == gender;
//     return GestureDetector(
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: 16.w,
//           vertical: isSelected ? 10.h : 14.h,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primary50 : Colors.transparent,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: isSelected ? AppColors.primary600 : Colors.transparent,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(gender, style: Styles.textStyle16),
//             const Spacer(),
//             if (isSelected)
//               Icon(Icons.check_circle, color: AppColors.primary400, size: 28.w),
//           ],
//         ),
//       ),
//     );
//   }
// }
