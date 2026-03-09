import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart' as di;
import 'package:tayseer/features/advisor/update_posts/view_model/update_posts_state.dart';
import 'package:tayseer/my_import.dart';

class UpdatePostCubit extends Cubit<UpdatePostState> {
  UpdatePostCubit({PostsRepository? repository})
    : _repo = repository ?? di.getIt<PostsRepository>(),
      super(const UpdatePostState());

  final PostsRepository _repo;
  final contentController = TextEditingController();
  String? _pendingCategoryName;

  // ════════════════════════════════════════════
  // ✅ تهيئة الكيوبت بداتا البوست
  // ════════════════════════════════════════════
  void initWithPost(PostModel post) {
    final postType = post.isReel ? AddPostEnum.reel : AddPostEnum.post;

    emit(
      state.copyWith(
        editPostId: post.postId,
        draftText: post.content,
        existingImageUrls: post.images.map((e) => e.image).toList(),
        existingVideoUrl: post.videoData?.video,
        resolvedPostType: postType,
        selectedCategoryId: null,
        // ✅ مسح قوائم الحذف عند البداية
        imagesToDelete: [],
        videosToDelete: [],
      ),
    );

    contentController.text = post.content;
    _pendingCategoryName = post.category;

    if (state.categories.isNotEmpty) {
      _resolveCategoryId();
    }
  }

  // ════════════════════════════════════════════
  // ✅ Mapping اسم الكاتيجوري → id
  // ════════════════════════════════════════════
  void _resolveCategoryId() {
    if (_pendingCategoryName == null) return;
    if (state.categories.isEmpty) return;

    final match = state.categories.where(
      (c) =>
          c.name.trim().toLowerCase() ==
          _pendingCategoryName!.trim().toLowerCase(),
    );

    if (match.isNotEmpty) {
      emit(state.copyWith(selectedCategoryId: match.first.id));
      debugPrint(
        '✅ Category resolved: ${match.first.name} → ${match.first.id}',
      );
      _pendingCategoryName = null;
    } else {
      debugPrint('⚠️ Category not found: $_pendingCategoryName');
    }
  }

  // ════════════════════════════════════════════
  // ✅ تحديد نوع البوست تلقائياً
  // ════════════════════════════════════════════
  void _resolvePostType() {
    final hasVideo =
        state.capturedVideo != null || state.existingVideoUrl != null;

    emit(
      state.copyWith(
        resolvedPostType: hasVideo ? AddPostEnum.reel : AddPostEnum.post,
      ),
    );
  }

  // ════════════════════════════════════════════
  // ✅ حذف صورة موجودة من السيرفر
  // ════════════════════════════════════════════
  void removeExistingImage(String imageUrl) {
    // ✅ امسحها من العرض
    final updatedExisting = List<String>.from(state.existingImageUrls);
    updatedExisting.remove(imageUrl);

    // ✅ ضيفها في قائمة الحذف عشان تتبعت للباك
    final updatedToDelete = List<String>.from(state.imagesToDelete);
    if (!updatedToDelete.contains(imageUrl)) {
      updatedToDelete.add(imageUrl);
    }

    debugPrint('🗑️ Image marked for deletion: $imageUrl');
    debugPrint('🗑️ imagesToDelete: $updatedToDelete');

    emit(
      state.copyWith(
        existingImageUrls: updatedExisting,
        imagesToDelete: updatedToDelete,
      ),
    );
  }

  // ════════════════════════════════════════════
  // ✅ حذف الفيديو الموجود من السيرفر
  // ════════════════════════════════════════════
  void removeExistingVideo() {
    final videoUrl = state.existingVideoUrl;

    // ✅ ضيف الفيديو في قائمة الحذف عشان يتبعت للباك
    final updatedToDelete = List<String>.from(state.videosToDelete);
    if (videoUrl != null && !updatedToDelete.contains(videoUrl)) {
      updatedToDelete.add(videoUrl);
    }

    debugPrint('🗑️ Video marked for deletion: $videoUrl');
    debugPrint('🗑️ videosToDelete: $updatedToDelete');

    emit(
      state.copyWith(existingVideoUrl: null, videosToDelete: updatedToDelete),
    );

    _resolvePostType();
  }

  // ════════════════════════════════════════════
  // ✅ إضافة صورة جديدة
  // ════════════════════════════════════════════
  Future<void> addCapturedImage(File file) async {
    try {
      if (state.capturedVideo != null || state.existingVideoUrl != null) {
        return;
      }
      final captured = List<File>.from(state.capturedImages);
      captured.add(file);
      emit(state.copyWith(capturedImages: captured));
    } catch (e) {
      debugPrint('addCapturedImage error: $e');
    }
  }

  // ════════════════════════════════════════════
  // ✅ حذف صورة جديدة (من الكاميرا - مش من السيرفر)
  // ════════════════════════════════════════════
  void removeCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages);
    captured.remove(file);
    emit(state.copyWith(capturedImages: captured));
  }

  // ════════════════════════════════════════════
  // ✅ إضافة فيديو جديد
  // ════════════════════════════════════════════
  Future<void> addCapturedVideo(XFile file) async {
    try {
      if (state.capturedImages.isNotEmpty ||
          state.existingImageUrls.isNotEmpty) {
        return;
      }
      emit(state.copyWith(capturedVideo: file));
      _resolvePostType();
    } catch (e) {
      debugPrint('addCapturedVideo error: $e');
    }
  }

  // ════════════════════════════════════════════
  // ✅ حذف فيديو جديد (من الكاميرا - مش من السيرفر)
  // ════════════════════════════════════════════
  void removeCapturedVideo() {
    emit(state.copyWith(capturedVideo: null));
    _resolvePostType();
  }

  // ════════════════════════════════════════════
  // ✅ تحديث فيديو معدل
  // ════════════════════════════════════════════
  void updateCapturedVideo(XFile newVideo) {
    emit(state.copyWith(capturedVideo: newVideo));
    _resolvePostType();
  }

  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  void setSelectedCategoryId(String id) {
    emit(state.copyWith(selectedCategoryId: id));
  }

  // ════════════════════════════════════════════
  // ✅ تحميل الكاتيجوريز
  // ════════════════════════════════════════════
  Future<void> getALLCategory() async {
    emit(state.copyWith(categoryState: CubitStates.loading));

    final response = await _repo.getALLCategory("1");

    response.fold(
      (failure) => emit(
        state.copyWith(
          categoryState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (data) {
        emit(
          state.copyWith(
            categoryState: CubitStates.success,
            categories: data.categories,
            currentPage: data.pagination.currentPage,
            totalPages: data.pagination.totalPages,
          ),
        );
        _resolveCategoryId();
      },
    );
  }

  Future<void> loadMoreCategories() async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.totalPages) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final response = await _repo.getALLCategory(nextPage.toString());

    response.fold((_) => emit(state.copyWith(isLoadingMore: false)), (data) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          categories: [...state.categories, ...data.categories],
          currentPage: data.pagination.currentPage,
          totalPages: data.pagination.totalPages,
        ),
      );
      _resolveCategoryId();
    });
  }

  // ════════════════════════════════════════════
  // ✅ Update Post
  // ════════════════════════════════════════════
  Future<void> updatePost() async {
    if (state.editPostId == null) return;

    emit(state.copyWith(updatePostState: CubitStates.loading));

    debugPrint('📤 imagesToDelete: ${state.imagesToDelete}');
    debugPrint('📤 videosToDelete: ${state.videosToDelete}');
    debugPrint('📤 newImages: ${state.capturedImages.length}');
    debugPrint('📤 newVideo: ${state.capturedVideo?.path}');

    final response = await _repo.updatePosts(
      idPost: state.editPostId,
      content: contentController.text,
      categoryId: state.selectedCategoryId ?? '',
      postType: state.resolvedPostType.name,
      // ✅ صور جديدة
      imageFiles: state.capturedImages.isNotEmpty ? state.capturedImages : null,
      // ✅ فيديو جديد
      videoFile: state.capturedVideo,
      // ✅ الصور المحذوفة من السيرفر
      imagesToDelete: state.imagesToDelete.isNotEmpty
          ? state.imagesToDelete
          : null,
      // ✅ الفيديوهات المحذوفة من السيرفر
      videosToDelete: state.videosToDelete.isNotEmpty
          ? state.videosToDelete
          : null,
    );

    response.fold(
      (failure) => emit(
        state.copyWith(
          updatePostState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            updatePostState: CubitStates.success,
            capturedImages: [],
            capturedVideo: null,
            existingImageUrls: [],
            existingVideoUrl: null,
            imagesToDelete: [],
            videosToDelete: [],
            draftText: '',
          ),
        );
        contentController.clear();
      },
    );
  }

  // ════════════════════════════════════════════
  // ✅ AI Enhance
  // ════════════════════════════════════════════
  Future<void> enhanceTextWithGemini(BuildContext context) async {
    final currentText = contentController.text;

    if (currentText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('please_write_text_first'),
          isError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isAiLoading: true));

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      emit(state.copyWith(isAiLoading: false));
      return;
    }

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);

      final prompt =
          '''
You are a professional social media content creator.
IMPORTANT RULES:
1. Detect the language of the input text
2. Rewrite the text in THE SAME LANGUAGE as the input
3. Make it engaging, professional, and attractive for social media
4. Add relevant emojis
5. Do NOT translate - keep the same language
6. Return ONLY the rewritten text, nothing else
Input text: "$currentText"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        contentController.text = response.text!;
        emit(state.copyWith(draftText: response.text!, isAiLoading: false));
      }
    } catch (e) {
      debugPrint('Gemini AI error: $e');
      emit(state.copyWith(isAiLoading: false));
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'AI Error: ${e.toString()}',
          isError: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    contentController.dispose();
    return super.close();
  }
}
