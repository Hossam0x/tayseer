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
      buildWhen: (previous, current) =>
          previous.state != current.state ||
          previous.mentions != current.mentions,
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

        // ✅ MODIFIED: فصل الشيمر عن القائمة في الـ Container
        if (state.state == CubitStates.loading && state.mentions.isEmpty) {
          // ✅ الشيمر: Container بدون maxHeight، يلف المحتوى بس
          return Container(
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
            child: _buildShimmer(),
          );
        }

        // ✅ القائمة الحقيقية: Container بـ maxHeight
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
          child: _buildMentionsList(state.mentions),
        );
      },
    );
  }

  Widget _buildMentionsList(List<MentionSearchModel> mentions) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(mentions.length, (index) {
          final user = mentions[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0) Divider(height: 1, color: Colors.grey.shade200),
              _MentionTile(
                key: ValueKey(user.username),
                user: user,
                onTap: () => onMentionSelected(user),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
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
                mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

class _MentionTile extends StatelessWidget {
  final MentionSearchModel user;
  final VoidCallback onTap;

  const _MentionTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: RepaintBoundary(
        child: ClipOval(
          child: AppImage(
            user.image ?? '',
            width: 36.w,
            height: 36.w,
            isAvatar: true,
            blur: user.imageBlur ? 1.5 : 0.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              user.name ?? user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          if (user.isVerified == true) ...[
            SizedBox(width: 4.w),
            Icon(Icons.verified, color: Colors.blue, size: 16.sp),
          ],
        ],
      ),
      subtitle: Text(
        user.username,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }
}
