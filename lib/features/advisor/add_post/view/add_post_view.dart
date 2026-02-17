import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/add_post_body.dart';
import 'package:tayseer/my_import.dart';

class AddPostView extends StatelessWidget {
  const AddPostView({
    super.key,
    this.addPostEnum = AddPostEnum.post,
    this.post,
    this.isEdit = false,
  });
  final AddPostEnum? addPostEnum;
  final PostModel? post;
  final bool isEdit;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AddPostBody());
  }
}
