import 'dart:ui';
import 'package:tayseer/core/enum/verification_type.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart';

class VisitorItem extends StatelessWidget {
  final ProfileVisitorModel visitor;
  final bool canSeeVisitors; // true only for ultra

  const VisitorItem({
    super.key,
    required this.visitor,
    required this.canSeeVisitors,
  });

  void _navigateToProfile(BuildContext context) {
    if (!canSeeVisitors) return;
    if (visitor.userType == 'User') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserPublicProfileView(userId: visitor.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserAdvisorProfileView(advisorId: visitor.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: canSeeVisitors
                    ? CachedNetworkImage(
                        imageUrl: visitor.image ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.white,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(color: Colors.white),
                        ),
                      )
                    : ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: CachedNetworkImage(
                          imageUrl: visitor.image ?? '',
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.white,
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[200]),
                        ),
                      ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          canSeeVisitors ? visitor.name : '••••••',
                          style: Styles.textStyle16SemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (canSeeVisitors &&
                          visitor.verificationType ==
                              VerificationType.full) ...[
                        Gap(4.w),
                        Icon(Icons.verified, color: Colors.blue, size: 16.w),
                      ] else if (canSeeVisitors &&
                          visitor.verificationType ==
                              VerificationType.basic) ...[
                        Gap(4.w),
                        Icon(Icons.verified, color: Colors.grey, size: 16.w),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (canSeeVisitors)
              CustomBotton(
                title: context.tr('show'),
                onPressed: () => _navigateToProfile(context),
                useGradient: true,
                width: 85.w,
                height: 45.h,
                radius: 10.r,
              )
            else
              CustomBotton(
                title: context.tr('show'),
                onPressed: () {},
                backGroundcolor: AppColors.secondary300,
                width: 85.w,
                height: 45.h,
                radius: 10.r,
              ),
          ],
        ),
      ),
    );
  }
}
