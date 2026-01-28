// import 'package:flutter/material.dart';
// import 'package:tayseer/core/widgets/simple_app_bar.dart';
// import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
// import 'package:tayseer/my_import.dart';

// class MarriageProfileEditView extends StatefulWidget {
//   final UserProfileModel initialProfile;
//   final Function(UserProfileModel) onProfileUpdated;

//   const MarriageProfileEditView({
//     super.key,
//     required this.initialProfile,
//     required this.onProfileUpdated,
//   });

//   @override
//   State<MarriageProfileEditView> createState() =>
//       _MarriageProfileEditViewState();
// }

// class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
//   // بيانات الزواج المؤقتة
//   late String country;
//   late String nationality;
//   late String religion;
//   late int age;
//   late String height;
//   late String bodyType;
//   late String healthStatus;
//   late String financialStatus;
//   late String smoking;
//   late String occupation;
//   late String jobTitle;
//   late String professionalLevel;
//   late String religiosity;

//   @override
//   void initState() {
//     super.initState();
//     // تحميل البيانات من الـ profile
//     _initializeData();
//   }

//   void _initializeData() {
//     // TODO: استبدل هذه القيم من widget.initialProfile
//     country = 'مصر';
//     nationality = 'مصري';
//     religion = 'مسلم';
//     age = 28;
//     height = '170 - 180 سم';
//     bodyType = 'متوسط';
//     healthStatus = 'سليم';
//     financialStatus = 'جيد';
//     smoking = 'لا';
//     occupation = 'مهندس';
//     jobTitle = 'مهندس برمجيات';
//     professionalLevel = 'موظف';
//     religiosity = 'متدين';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               AssetsData.homeBarBackgroundImage,
//               fit: BoxFit.cover,
//             ),
//           ),
//           AdvisorBackground(
//             child: Column(
//               children: [
//                 SimpleAppBar(
//                   title: "تعديل ملف الزواج",
//                   isLargeTitle: true,
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.symmetric(horizontal: 20.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Gap(20.h),
                        
//                         Text(
//                           "معلومات عني",
//                           style: Styles.textStyle18Bold.copyWith(
//                             color: Color(0xFF000000),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
                        
//                         Gap(16.h),
                        
//                         _buildMarriageFieldsList(),
                        
//                         Gap(40.h),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMarriageFieldsList() {
//     final List<MarriageField> fields = [
//       MarriageField('البلد', country, 'country'),
//       MarriageField('الجنسية', nationality, 'nationality'),
//       MarriageField('الدين', religion, 'religion'),
//       MarriageField('السن', '$age سنة', 'age'),
//       MarriageField('الطول', height, 'height'),
//       MarriageField('بنية الجسم', bodyType, 'bodyType'),
//       MarriageField('الحالة الصحية', healthStatus, 'healthStatus'),
//       MarriageField('الوضع المالي', financialStatus, 'financialStatus'),
//       MarriageField('التدخين', smoking, 'smoking'),
//       MarriageField('الوظيفة', occupation, 'occupation'),
//       MarriageField('الوصف الوظيفي', jobTitle, 'jobTitle'),
//       MarriageField('الدرجة الوظيفية', professionalLevel, 'professionalLevel'),
//       MarriageField('التدين', religiosity, 'religiosity'),
//     ];

//     return Column(
//       children: [
//         for (var i = 0; i < fields.length; i++) ...[
//           _buildFieldItem(fields[i]),
//           if (i < fields.length - 1)
//             Divider(color: AppColors.secondary100, height: 1),
//         ],
//       ],
//     );
//   }

//   Widget _buildFieldItem(MarriageField field) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _editField(field),
//         borderRadius: BorderRadius.circular(16.r),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   field.label,
//                   style: Styles.textStyle16Meduim.copyWith(
//                     color: AppColors.secondary800,
//                   ),
//                 ),
//               ),
//               Container(
//                 constraints: BoxConstraints(maxWidth: 120.w),
//                 child: Text(
//                   field.value,
//                   style: Styles.textStyle16.copyWith(
//                     color: AppColors.secondary,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//               Gap(4.w),
//               Icon(Icons.arrow_forward_ios_rounded, size: 16.w),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _editField(MarriageField field) {
//     // TODO: فتح صفحة اختيار القيمة
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MarriageFieldSelectionView(
//           fieldName: field.id,
//           currentValue: field.value,
//           onValueSelected: (newValue) {
//             setState(() {
//               switch (field.id) {
//                 case 'country':
//                   country = newValue;
//                   break;
//                 case 'nationality':
//                   nationality = newValue;
//                   break;
//                 case 'religion':
//                   religion = newValue;
//                   break;
//                 case 'age':
//                   age = int.tryParse(newValue.replaceAll(' سنة', '')) ?? age;
//                   break;
//                 case 'height':
//                   height = newValue;
//                   break;
//                 case 'bodyType':
//                   bodyType = newValue;
//                   break;
//                 case 'healthStatus':
//                   healthStatus = newValue;
//                   break;
//                 case 'financialStatus':
//                   financialStatus = newValue;
//                   break;
//                 case 'smoking':
//                   smoking = newValue;
//                   break;
//                 case 'occupation':
//                   occupation = newValue;
//                   break;
//                 case 'jobTitle':
//                   jobTitle = newValue;
//                   break;
//                 case 'professionalLevel':
//                   professionalLevel = newValue;
//                   break;
//                 case 'religiosity':
//                   religiosity = newValue;
//                   break;
//               }
//             });
//           },
//         ),
//       ),
//     );
//   }
// }

// class MarriageField {
//   final String label;
//   final String value;
//   final String id;

//   MarriageField(this.label, this.value, this.id);
// }

// // Placeholder لصفحة اختيار القيمة
// class MarriageFieldSelectionView extends StatelessWidget {
//   final String fieldName;
//   final String currentValue;
//   final Function(String) onValueSelected;

//   const MarriageFieldSelectionView({
//     super.key,
//     required this.fieldName,
//     required this.currentValue,
//     required this.onValueSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('اختر القيمة')),
//       body: Center(
//         child: Text('صفحة اختيار $fieldName'),
//       ),
//     );
//   }
// }