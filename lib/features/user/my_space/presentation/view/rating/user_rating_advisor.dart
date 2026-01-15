import 'package:tayseer/features/user/my_space/presentation/widget/rating/user_rating_advisor_body.dart';
import 'package:tayseer/my_import.dart';

class RatingView extends StatelessWidget {
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AdvisorBackground(child: RatingViewBody()));
  }
}
