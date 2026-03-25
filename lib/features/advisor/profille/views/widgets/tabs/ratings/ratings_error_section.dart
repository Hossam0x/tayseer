import 'package:tayseer/features/advisor/profille/views/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/my_import.dart';

class RatingsErrorSection extends StatelessWidget {
  final String advisorId;

  const RatingsErrorSection({super.key, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    final state = context.read<RatingsCubit>().state;
    return CustomErrorView(
      message: state.errorMessage,
      onRetry: () =>
          context.read<RatingsCubit>().refresh(advisorId: advisorId),
    );
  }
}
