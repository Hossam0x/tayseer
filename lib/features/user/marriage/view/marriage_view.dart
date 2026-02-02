import 'package:tayseer/features/user/marriage/view/widget/marriage_body.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/my_import.dart';

class MarriageView extends StatelessWidget {
  const MarriageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MarriageCubit(),
        child: const MarriageBody(),
      ),
    );
  }
}
