import 'package:tayseer/features/advisor/add_post/view/widget/camera_body.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/my_import.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key, required this.cubit});
  final AddPostCubit cubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: CameraBody(cubit: cubit),
    );
  }
}
