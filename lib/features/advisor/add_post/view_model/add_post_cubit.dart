import 'package:tayseer/core/services/groq_service.dart';
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

    final response = await _repo.getALLCategory("1");

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            categoryState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            categoryState: CubitStates.success,
            categories: data.categories,
            currentPage: data.pagination.currentPage,
            totalPages: data.pagination.totalPages,
          ),
        );
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
    });
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
      debugPrint(
        '🎬 [AddPostCubit] addCapturedVideo called with path: ${file.path}',
      );
      // Only allow a single captured video — replace any existing one
      emit(state.copyWith(capturedVideo: file));
      debugPrint(
        '🎬 [AddPostCubit] state.capturedVideo updated to: ${file.path}',
      );
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

  /// ✅ تحديث الفيديو المعدل (بدل remove + add)
  void updateCapturedVideo(XFile newVideo) {
    debugPrint(
      '🎬 [AddPostCubit] updateCapturedVideo called with: ${newVideo.path}',
    );
    emit(state.copyWith(capturedVideo: newVideo));
    debugPrint(
      '🎬 [AddPostCubit] state.capturedVideo updated to: ${newVideo.path}',
    );
    _resolvePostType();
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

    try {
      final groq = di.getIt<GroqService>();
      final prompt =
          'You are a professional social media content creator.\n'
          'IMPORTANT RULES:\n'
          '1. Rewrite the text to be engaging, professional, and attractive for social media\n'
          '2. Add relevant emojis\n'
          '3. Return ONLY the rewritten text, nothing else\n'
          'Input text: "$currentText"';

      final result = await groq.generateText(prompt);
      contentController.text = result;
      emit(state.copyWith(draftText: result, isAiLoading: false));
    } catch (e) {
      debugPrint('Groq AI error: $e');
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
