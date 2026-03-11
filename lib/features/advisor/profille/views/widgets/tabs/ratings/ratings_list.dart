import 'package:tayseer/features/advisor/profille/views/cubit/ratings_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings/rating_item_card.dart';
import 'package:tayseer/my_import.dart';

class RatingsList extends StatelessWidget {
  final RatingsState state;

  const RatingsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.ratings.length,
      separatorBuilder: (context, index) => Gap(16.h),
      itemBuilder: (context, index) => RatingItemCard(rating: state.ratings[index]),
    );
  }
}
