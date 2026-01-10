import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> fetchUserPosts(String userId) async {
    emit(ProfileLoading());

    try {
      // TODO: جلب منشورات المستخدم من API
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية
      final List<PostModel> userPosts = [];

      emit(ProfilePostsLoaded(posts: userPosts));
    } catch (e) {
      emit(ProfileError(message: "حدث خطأ في جلب البيانات"));
    }
  }

  Future<void> fetchUserComments(String userId) async {
    // TODO: جلب تعليقات المستخدم من API
  }

  Future<void> deletePost(String postId) async {
    // TODO: حذف منشور
  }

  Future<void> editPost(String postId, String newContent) async {
    // TODO: تعديل منشور
  }
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfilePostsLoaded extends ProfileState {
  final List<PostModel> posts;

  ProfilePostsLoaded({required this.posts});
}

class ProfileCommentsLoaded extends ProfileState {
  final List<CommentModel> comments;

  ProfileCommentsLoaded({required this.comments});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
