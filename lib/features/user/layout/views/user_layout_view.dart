// features/advisor/layout/views/a_layout_view.dart
import 'package:tayseer/features/user/layout/views/widgets/user_layout_view_body.dart';
import 'package:tayseer/my_import.dart';

class UserLayoutView extends StatelessWidget {
  const UserLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LayoutCubit(),
        child: const UserLayOutViewBody(),
      ),
    );
  }
}
