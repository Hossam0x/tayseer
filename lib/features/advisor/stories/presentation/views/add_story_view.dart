import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/add_story_body.dart';
import 'package:tayseer/my_import.dart';

class AddStoryView extends StatelessWidget {
  const AddStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddStoryCubit(getIt()),
      child: const Scaffold(body: AddStoryBody()),
    );
  }
}
