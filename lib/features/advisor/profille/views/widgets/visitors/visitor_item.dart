import 'package:tayseer/features/advisor/profille/data/models/profile_visitors_model.dart';
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
    final hasImage = visitor.image != null && visitor.image!.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundImage: hasImage ? NetworkImage(visitor.image!) : null,
          child: hasImage ? null : Icon(Icons.person, size: 24.sp),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSubscribed ? visitor.name : '••••••',
                style: Styles.textStyle16.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                visitor.userType,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary600,
                ),
              ),
            ],
          ),
        ),
        Text(
          visitor.lastVisitedAt,
          style: Styles.textStyle12.copyWith(color: AppColors.secondary400),
        ),
      ],
    );
  }
}
