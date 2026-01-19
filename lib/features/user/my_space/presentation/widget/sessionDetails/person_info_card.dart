import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonInfoCard extends StatelessWidget {
  final String name;
  final String handle;
  final String imageUrl;
  final VoidCallback? onTap;

  const PersonInfoCard({
    super.key,
    required this.name,
    required this.handle,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 15.w),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 25.r,
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: imageUrl.isNotEmpty ? (_, __) {} : null,
      child: imageUrl.isEmpty
          ? Icon(Icons.person, size: 25.sp, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            handle,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
