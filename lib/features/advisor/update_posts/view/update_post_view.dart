import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/update_posts/view/widget/update_post_body.dart';
import 'package:tayseer/features/advisor/update_posts/view_model/update_posts_cubit.dart';
import 'package:tayseer/my_import.dart';

class UpdatePostView extends StatefulWidget {
  const UpdatePostView({super.key, required this.post});
  final PostModel post;

  @override
  State<UpdatePostView> createState() => _UpdatePostViewState();
}

class _UpdatePostViewState extends State<UpdatePostView> {
  @override
  void initState() {
    super.initState();
    // ✅ تهيئة الداتا بعد بناء الـ Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdatePostCubit>().initWithPost(widget.post);
      // ✅ لو الكاتيجوريز فارغة حملها
      if (context.read<UpdatePostCubit>().state.categories.isEmpty) {
        context.read<UpdatePostCubit>().getALLCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: UpdatePostBody());
  }
}
