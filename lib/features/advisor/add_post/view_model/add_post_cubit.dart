import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart' as di;
import 'package:tayseer/my_import.dart';

class AddPostCubit extends Cubit<AddPostState> {
  AddPostCubit({PostsRepository? repository})
    : _repo = repository ?? di.getIt<PostsRepository>(),
      super(const AddPostState());

  final PostsRepository _repo;
  final contentController = TextEditingController();

  // ✅ تحديد نوع البوست تلقائياً بناءً على المحتوى
  void _resolvePostType() {
    final hasVideo =
        state.selectedVideos.isNotEmpty || state.capturedVideo != null;

    if (hasVideo) {
      emit(state.copyWith(resolvedPostType: AddPostEnum.reel));
    } else {
      emit(state.copyWith(resolvedPostType: AddPostEnum.post));
    }
  }

  /// Create post using repository (uses current state for content/media)
  Future<void> createPost({
    required String categoryId,
    required String postType,
  }) async {
    emit(state.copyWith(addPostState: CubitStates.loading));

    // source 1: gallery images
    final galleryImages = state.selectedImages.isNotEmpty
        ? state.selectedImages
        : null;

    // source 2: captured images (camera)
    final cameraImages = state.capturedImages.isNotEmpty
        ? state.capturedImages
        : null;

    final response = await _repo.createPost(
      content: contentController.text,
      categoryId: categoryId,
      postType: postType,
      images: galleryImages,
      imageFiles: cameraImages,
      videoFile: state.capturedVideo,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            addPostState: CubitStates.failure,
            errorMessage: failure.message,
            loading: false,
          ),
        );
      },
      (_) {
        // success - clear draft and selections
        emit(
          state.copyWith(
            addPostState: CubitStates.success,
            loading: false,
            selectedImages: [],
            capturedImages: [],
            capturedVideo: null,
            draftText: '',
            resolvedPostType: AddPostEnum.post, // ✅ reset بعد النشر
          ),
        );
        contentController.clear();
      },
    );
  }

  /// Get All category
  Future<void> getALLCategory() async {
    emit(state.copyWith(categoryState: CubitStates.loading));

    final response = await _repo.getALLCategory();

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            categoryState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (categories) {
        emit(
          state.copyWith(
            categoryState: CubitStates.success,
            categories: categories,
          ),
        );
      },
    );
  }

  /// حذف صورة من اللي تحت الـ TextField
  void removeSelected(AssetEntity image) {
    final selected = List<AssetEntity>.from(state.selectedImages);
    selected.remove(image);
    emit(state.copyWith(selectedImages: selected));
    _resolvePostType(); // ✅
  }

  /// 🔥 حذف صورة ملتقطة من الكاميرا
  void removeCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages);
    captured.remove(file);
    emit(state.copyWith(capturedImages: captured));
    _resolvePostType(); // ✅
  }

  /// Update the draft text from the UI
  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  /// Set the selected category id from UI
  void setSelectedCategoryId(String id) {
    emit(state.copyWith(selectedCategoryId: id));
  }

  /// 🔥 إضافة صورة ملتقطة من الكاميرا مباشرة بدون حفظها في الجاليري
  Future<void> addCapturedImage(File file) async {
    try {
      // ❌ لو فيه فيديو محمل، منع إضافة صور
      if (state.capturedVideo != null || state.selectedVideos.isNotEmpty) {
        return;
      }
      final captured = List<File>.from(state.capturedImages);
      captured.add(file);
      emit(state.copyWith(capturedImages: captured));
      _resolvePostType(); // ✅
    } catch (e) {
      debugPrint('addCapturedImage error: $e');
    }
  }

  /// 🔥 إضافة فيديو ملتقط من المعرض/الكاميرا
  Future<void> addCapturedVideo(XFile file) async {
    try {
      // ❌ لو فيه صور محملة، منع إضافة فيديو
      if (state.capturedImages.isNotEmpty || state.selectedImages.isNotEmpty) {
        return;
      }
      // Only allow a single captured video — replace any existing one
      emit(state.copyWith(capturedVideo: file));
      _resolvePostType(); // ✅
    } catch (e) {
      debugPrint('addCapturedVideo error: $e');
    }
  }

  /// Remove a captured video file
  void removeCapturedVideo() {
    emit(state.copyWith(capturedVideo: null));
    _resolvePostType(); // ✅
  }

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

    const apiKey = 'AIzaSyAzkpmYLG58vfNtxPGvfh8Ynix02VNWnUg';

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
}
