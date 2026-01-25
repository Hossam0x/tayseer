import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
import 'package:tayseer/my_import.dart';

class InteractionsView extends StatelessWidget {
  const InteractionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
      create: (context) => getIt<InteractionsCubit>(),
      child: InteractionBody(),
    );
  }
}
