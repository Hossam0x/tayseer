// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tayseer/core/widgets/simple_app_bar.dart';
// import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
// import 'package:tayseer/my_import.dart';

// class EditProfileImageView extends StatefulWidget {
//   final UserProfileModel initialProfile;
//   final Function(UserProfileModel) onProfileUpdated;

//   const EditProfileImageView({
//     super.key,
//     required this.initialProfile,
//     required this.onProfileUpdated,
//   });

//   @override
//   State<EditProfileImageView> createState() => _EditProfileImageViewState();
// }

// class _EditProfileImageViewState extends State<EditProfileImageView> {
//   final ImagePicker _picker = ImagePicker();
//   XFile? _selectedImage;
//   bool _isLoading = false;
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     // يمكنك تحميل الصورة الحالية إذا لزم الأمر
//   }

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = pickedFile;
//         });
//         // رفع الصورة تلقائياً عند الاختيار
//         await _uploadImage();
//       }
//     } catch (e) {
//       AppToast.error(context, 'حدث خطأ في اختيار الصورة: $e');
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) return;

//     setState(() => _isUploading = true);

//     try {
//       final apiService = getIt<ApiService>();
//       final response = await apiService.patch(
//         endPoint: '/user/update-profile',
//         isFromData: true,
//         data: {
//           'image': await MultipartFile.fromFile(
//             _selectedImage!.path,
//             filename: 'profile_image.jpg',
//           ),
//         },
//       );

//       if (response['success'] == true) {
//         final imageUrl = response['data']['image'] as String?;
//         final updatedProfile = widget.initialProfile.copyWith(image: imageUrl);
//         widget.onProfileUpdated(updatedProfile);

//         AppToast.success(context, 'تم تحديث الصورة الشخصية بنجاح');
//       } else {
//         AppToast.error(context, response['message'] ?? 'فشل تحديث الصورة');
//       }
//     } catch (e) {
//       AppToast.error(context, 'حدث خطأ: $e');
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }

//   Future<void> _removeImage() async {
//     if (widget.initialProfile.image == null ||
//         widget.initialProfile.image!.isEmpty) {
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final apiService = getIt<ApiService>();
//       final response = await apiService.patch(
//         endPoint: '/user/update-profile',
//         isFromData: true,
//         data: {'image': ''}, // إرسال قيمة فارغة لحذف الصورة
//       );

//       if (response['success'] == true) {
//         final updatedProfile = widget.initialProfile.copyWith(image: '');
//         widget.onProfileUpdated(updatedProfile);

//         AppToast.success(context, 'تم حذف الصورة الشخصية بنجاح');
//         setState(() {
//           _selectedImage = null;
//         });
//       } else {
//         AppToast.error(context, response['message'] ?? 'فشل حذف الصورة');
//       }
//     } catch (e) {
//       AppToast.error(context, 'حدث خطأ: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildImagePreview() {
//     if (_isUploading) {
//       return Center(
//         child: CircularProgressIndicator(color: AppColors.primary500),
//       );
//     }

//     if (_selectedImage != null) {
//       return Image.file(
//         File(_selectedImage!.path),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       );
//     }

//     if (widget.initialProfile.image != null &&
//         widget.initialProfile.image!.isNotEmpty) {
//       return Image.network(
//         widget.initialProfile.image!,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildDefaultAvatar();
//         },
//       );
//     }

//     return _buildDefaultAvatar();
//   }

//   Widget _buildDefaultAvatar() {
//     return Center(
//       child: Icon(Icons.person, size: 80.w, color: AppColors.secondary300),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SimpleAppBar(title: 'تعديل الصورة الشخصية', isLargeTitle: true),

//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
//                 child: Column(
//                   children: [
//                     // معاينة الصورة
//                     Container(
//                       width: 200.w,
//                       height: 200.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppColors.secondary100,
//                         border: Border.all(
//                           color: AppColors.secondary200,
//                           width: 2,
//                         ),
//                       ),
//                       child: ClipOval(child: _buildImagePreview()),
//                     ),

//                     Gap(24.h),

//                     // أزرار التحكم
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // زر تغيير الصورة
//                         _buildActionButton(
//                           icon: Icons.camera_alt,
//                           label: 'تغيير الصورة',
//                           onTap: _pickImage,
//                           color: AppColors.primary500,
//                         ),

//                         Gap(16.w),

//                         // زر حذف الصورة
//                         if (widget.initialProfile.image != null &&
//                             widget.initialProfile.image!.isNotEmpty)
//                           _buildActionButton(
//                             icon: Icons.delete,
//                             label: 'حذف الصورة',
//                             onTap: _removeImage,
//                             color: AppColors.kRedColor,
//                             isLoading: _isLoading,
//                           ),
//                       ],
//                     ),

//                     Gap(24.h),

//                     // تعليمات
//                     Text(
//                       'انقر على أيقونة الكاميرا لتغيير الصورة',
//                       style: Styles.textStyle14.copyWith(
//                         color: AppColors.secondary400,
//                       ),
//                     ),

//                     Gap(8.h),

//                     Text(
//                       'سيتم رفع الصورة تلقائياً عند اختيارها',
//                       style: Styles.textStyle12.copyWith(
//                         color: AppColors.secondary300,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required Color color,
//     bool isLoading = false,
//   }) {
//     return Column(
//       children: [
//         Container(
//           width: 60.w,
//           height: 60.w,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color.withOpacity(0.1),
//             border: Border.all(color: color, width: 1.5),
//           ),
//           child: isLoading
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: color,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : IconButton(
//                   icon: Icon(icon, color: color),
//                   onPressed: onTap,
//                 ),
//         ),
//         Gap(8.h),
//         Text(label, style: Styles.textStyle12.copyWith(color: color)),
//       ],
//     );
//   }
// }
