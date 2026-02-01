import 'package:tayseer/my_import.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final String groupDescription;
  final int membersCount;
  final int postsCount;
  final bool isJoined;
  final VoidCallback onJoinToggle;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.groupDescription,
    required this.membersCount,
    required this.postsCount,
    required this.isJoined,
    required this.onJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المجموعة
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(groupImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // محتوى المجموعة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المجموعة
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        groupName,
                        style: Styles.textStyle16Bold.copyWith(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // شارة المجموعة الخاصة (اختياري)
                    Icon(Icons.group, size: 16.w, color: Colors.grey.shade600),
                  ],
                ),

                SizedBox(height: 4.h),

                // وصف المجموعة
                Text(
                  groupDescription,
                  style: Styles.textStyle14.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // إحصائيات المجموعة
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.people_outline,
                      text: '$membersCount عضو',
                    ),

                    SizedBox(width: 16.w),

                    _buildStatItem(
                      icon: Icons.message_outlined,
                      text: '$postsCount منشور',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // زر الانضمام/المغادرة
          GestureDetector(
            onTap: onJoinToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isJoined
                    ? Colors.grey.shade100
                    : AppColors.kprimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isJoined
                      ? Colors.grey.shade300
                      : AppColors.kprimaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                isJoined ? 'منضم' : 'انضم',
                style: Styles.textStyle14.copyWith(
                  color: isJoined
                      ? Colors.grey.shade700
                      : AppColors.kprimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: Colors.grey.shade500),
        SizedBox(width: 4.w),
        Text(
          text,
          style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
