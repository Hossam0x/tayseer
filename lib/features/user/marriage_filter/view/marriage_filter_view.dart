import 'package:tayseer/features/user/marriage_filter/view/widget/marriage_filter_view_body.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_cubit.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterView extends StatelessWidget {
  const MarriageFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MarriageFilterCubit(),
        child: MarriageFilterBody(),
      ),
    );
  }
}
