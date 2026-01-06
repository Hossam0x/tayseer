import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/add_post_body.dart';
import 'package:tayseer/my_import.dart';

class AddPostView extends StatelessWidget {
  const AddPostView({super.key, this.addPostEnum = AddPostEnum.post});
  final AddPostEnum addPostEnum;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AddPostBody(postType: addPostEnum));
  }
}
