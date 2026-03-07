import 'dart:developer';

import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/add_post_body.dart';
import 'package:tayseer/my_import.dart';

class AddPostView extends StatelessWidget {
  const AddPostView({super.key, this.post, this.isEdit = false});
  final PostModel? post;
  final bool isEdit;
  @override
  Widget build(BuildContext context) {
    log(
      ">>>>>>>>>>>>>>>>>>>>>>>>>post in add post view is : ${post?.content} ,  isEdit : $isEdit",
    );
    return Scaffold(body: AddPostBody());
  }
}
