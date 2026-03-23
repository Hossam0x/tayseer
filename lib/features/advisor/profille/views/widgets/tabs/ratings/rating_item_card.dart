import 'package:tayseer/core/utils/helper/date_time_helper.dart';
import 'package:tayseer/features/advisor/profille/data/models/rating_model.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/expandable_review_text.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class RatingItemCard extends StatelessWidget {
  final RatingModel rating;

  const RatingItemCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(imageUrl: rating.user.image),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewHeader(rating: rating),
                Gap(8.h),
                _StarRatingRow(ratingValue: rating.rating),
                Gap(12.h),
                ExpandableReviewText(text: rating.review),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;

  const _UserAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.r,
      height: 60.r,
      child: CircleAvatar(
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? Icon(Icons.person, color: AppColors.hintText, size: 24.sp)
            : null,
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  final RatingModel rating;

  const _ReviewHeader({required this.rating});

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<LanguageCubit>().state.languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          rating.user.name ?? context.tr('user'),
          style: Styles.textStyle16Bold.copyWith(color: AppColors.primaryText),
          textAlign: TextAlign.right,
        ),
        Text(
          DateTimeHelper.formatRatingDate(rating.createdAt, langCode),
          style: Styles.textStyle12.copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  final num ratingValue;

  const _StarRatingRow({required this.ratingValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        5,
        (starIndex) => Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: Icon(
            starIndex < ratingValue ? Icons.star : Icons.star_border,
            size: 18.sp,
            color: AppColors.primary400,
          ),
        ),
      ),
    );
  }
}
