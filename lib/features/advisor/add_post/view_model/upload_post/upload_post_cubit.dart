import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/features/advisor/add_post/model/created_post_data.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'upload_post_state.dart';

class UploadPostCubit extends Cubit<UploadPostProgressState> {
  final PostsRepository _repository;

  UploadPostCubit(this._repository) : super(const UploadPostProgressState());

  // ─────────────────────────────────────────
  // حفظ البيانات علشان retry
  // ─────────────────────────────────────────
  String? _lastCategoryId;
  String? _lastCategoryName;
  String? _lastPostType;
  String? _lastContent;
  List<File>? _lastImages;
  XFile? _lastVideo;

  // ─────────────────────────────────────────
  // يبدأ رفع البوست في الخلفية
  // ─────────────────────────────────────────
  Future<void> startUploadWithRetry({
    required String categoryId,
    required String categoryName,
    required String postType,
    required String content,
    List<File> images = const [],
    XFile? video,
  }) async {
    // حفظ البيانات للـ retry
    _lastCategoryId = categoryId;
    _lastCategoryName = categoryName;
    _lastPostType = postType;
    _lastContent = content;
    _lastImages = List.from(images);
    _lastVideo = video;

    await _upload(
      categoryId: categoryId,
      categoryName: categoryName,
      postType: postType,
      content: content,
      images: images,
      video: video,
    );
  }

  // ─────────────────────────────────────────
  // الرفع الفعلي
  // ─────────────────────────────────────────
  Future<void> _upload({
    required String categoryId,
    required String categoryName,
    required String postType,
    required String content,
    List<File> images = const [],
    XFile? video,
  }) async {
    emit(
      state.copyWith(status: UploadPostStatus.uploading, errorMessage: null),
    );

    final result = await _repository.createPost(
      categoryId: categoryId,
      postType: postType,
      content: content,
      imageFiles: images,
      videoFile: video,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: UploadPostStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (createdPost) async {
        emit(state.copyWith(status: UploadPostStatus.success));

        // 🔥 أضيف البوست بالـ real ID من السيرفر في أول الـ home feed والـ profile
        _fireCreatedEvent(
          createdPost: createdPost,
          categoryName: categoryName,
          content: content,
          postType: postType,
        );

        // اخفاء البانر بعد 3 ثواني
        await Future.delayed(const Duration(seconds: 3));

        if (!isClosed) {
          emit(const UploadPostProgressState());
        }

        _clearSavedData();
      },
    );
  }

  // ─────────────────────────────────────────
  // إعادة المحاولة
  // ─────────────────────────────────────────
  Future<void> retry() async {
    if (_lastCategoryId != null && _lastPostType != null) {
      await _upload(
        categoryId: _lastCategoryId!,
        categoryName: _lastCategoryName ?? '',
        postType: _lastPostType!,
        content: _lastContent ?? '',
        images: _lastImages ?? [],
        video: _lastVideo,
      );
    }
  }

  // ─────────────────────────────────────────
  // إخفاء البانر يدويًا
  // ─────────────────────────────────────────
  void dismiss() {
    _clearSavedData();
    emit(const UploadPostProgressState());
  }

  void _clearSavedData() {
    _lastCategoryId = null;
    _lastCategoryName = null;
    _lastPostType = null;
    _lastContent = null;
    _lastImages = null;
    _lastVideo = null;
  }

  // ─────────────────────────────────────────
  // بناء بوست من الـ real server data وإرساله للـ feeds
  // ─────────────────────────────────────────
  void _fireCreatedEvent({
    required CreatedPostData createdPost,
    required String categoryName,
    required String content,
    required String postType,
  }) {
    final userData = kCurrentUserData;
    if (userData == null) return;

    final realPost = PostModel(
      postId: createdPost.id,
      name: userData.name ?? '',
      userName: userData.username ?? '',
      advisorId: userData.id ?? '',
      isFollowing: false,
      avatar: userData.image ?? '',
      isVerified: userData.isVerified ?? false,
      category: categoryName,
      timeAgo: 'الآن',
      content: content,
      contentType: postType == 'reel'
          ? PostContentType.reel
          : PostContentType.post,
      commentsCount: 0,
      sharesCount: 0,
      likesCount: 0,
      isMine: true,
      userType: createdPost.userRef,
    );

    PostEventBus.instance.fire(
      PostEvent(
        type: PostEventType.created,
        postId: realPost.postId,
        sourceId: 'UploadPostCubit',
        createdPost: realPost,
        categoryName: categoryName,
      ),
    );
  }
}
