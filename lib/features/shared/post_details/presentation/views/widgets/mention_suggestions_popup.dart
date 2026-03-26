import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';
import 'package:tayseer/features/shared/post_details/data/models/mention_search_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/mention_search_cubit/mention_search_cubit.dart';

class MentionSuggestionsPopup extends StatelessWidget {
  final Function(MentionSearchModel) onMentionSelected;
  const MentionSuggestionsPopup({super.key, required this.onMentionSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MentionSearchCubit, MentionSearchState>(
      builder: (context, state) {
        if (state.state == CubitStates.initial) {
          return const SizedBox.shrink();
        }

        if (state.state == CubitStates.success && state.mentions.isEmpty) {
          return const SizedBox.shrink();
        }

        if (state.state == CubitStates.failure && state.mentions.isEmpty) {
          return const SizedBox.shrink();
        }

        Widget child = const SizedBox.shrink();

        if (state.state == CubitStates.loading) {
          child = _buildShimmer();
        } else if (state.state == CubitStates.success ||
            state.mentions.isNotEmpty) {
          child = _buildMentionsList(state.mentions);
        }

        return Container(
          constraints: BoxConstraints(maxHeight: 400.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  // ✅ extracted method للقائمة الحقيقية
  Widget _buildMentionsList(List<MentionSearchModel> mentions) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: mentions.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final user = mentions[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: AppImage(
            user.image ?? '',
            width: 36.w,
            height: 36.w,
            radius: 18.r,
            isAvatar: true,
            blur: user.imageBlur ? 1.5 : 0.0,
          ),
          // 👇 التعديل هنا 👇
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // استخدمنا Flexible عشان لو الاسم طويل جداً ميعملش Overflow
              Flexible(
                child: Text(
                  user.name ?? user.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // شرط إظهار علامة التوثيق
              if (user.isVerified == true) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.verified, // يمكنك تغييرها بصورة SVG لو عندك تصميم مخصص
                  color: Colors.blue,
                  size: 16.sp,
                ),
              ],
            ],
          ),
          // 👆 نهاية التعديل 👆
          subtitle: Text(
            user.username,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          onTap: () => onMentionSelected(user),
        );
      },
    );
  }

  // ✅ extracted method للشيمر
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemCount: 1,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 80.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
