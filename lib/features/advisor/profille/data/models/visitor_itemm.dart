import 'dart:ui';

import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart';

class VisitorItem extends StatelessWidget {
  final ProfileVisitorModel visitor;
  final bool isSubscribed;

  const VisitorItem({
    super.key,
    required this.visitor,
    required this.isSubscribed,
  });

  @override
  Widget build(BuildContext context) {
    // Basic date formatting
    // String dateStr = '';
    try {
      // final date = DateTime.parse(visitor.lastVisitedAt);
      // dateStr = intl.DateFormat('yyyy-MM-dd hh:mm a').format(date);
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        if (!isSubscribed) return;

        if (visitor.userType == 'User') {
          Navigator.pushNamed(
            context,
            AppRouter.kUserPublicProfileView,
            arguments: visitor.id,
          );
        } else if (visitor.userType == 'Advisor' ||
            visitor.userType == 'Adisor') {
          Navigator.pushNamed(
            context,
            AppRouter.kUserProfileView,
            arguments: {'advisorId': visitor.id, 'advisorName': visitor.name},
          );
        }
      },
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
                child: isSubscribed
                    ? CachedNetworkImage(
                        imageUrl: visitor.image ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: CachedNetworkImage(
                          imageUrl: visitor.image ?? '',
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white,
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          placeholder: (context, url) =>
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
                  Text(
                    visitor.name,
                    style: Styles.textStyle16SemiBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // if (dateStr.isNotEmpty) ...[
                  //   Gap(4.h),
                  //   Text(
                  //     dateStr,
                  //     style: Styles.textStyle12.copyWith(
                  //       color: AppColors.secondary600,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
            // Show arrow/action only if subscribed
            if (isSubscribed)
              CustomBotton(
                title: context.tr('show'),
                onPressed: () {
                  if (visitor.userType == 'User') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserPublicProfileView(userId: visitor.id),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserAdvisorProfileView(advisorId: visitor.id),
                      ),
                    );
                  }
                },
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
