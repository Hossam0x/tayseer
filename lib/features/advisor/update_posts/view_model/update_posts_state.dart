import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/my_import.dart';

class UpdatePostState {
  final CubitStates updatePostState;
  final CubitStates categoryState;

  final List<CategoryModel> categories;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  final String draftText;
  final String? selectedCategoryId;
  final String? errorMessage;
  final bool isAiLoading;
  final AddPostEnum resolvedPostType;

  final String? editPostId;
  final List<String> existingImageUrls;
  final String? existingVideoUrl;

  final List<File> capturedImages;
  final XFile? capturedVideo;

  // ✅ قوائم الحذف
  final List<String> imagesToDelete;
  final List<String> videosToDelete;

  const UpdatePostState({
    this.updatePostState = CubitStates.initial,
    this.categoryState = CubitStates.initial,
    this.categories = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.draftText = '',
    this.selectedCategoryId,
    this.errorMessage,
    this.isAiLoading = false,
    this.resolvedPostType = AddPostEnum.post,
    this.editPostId,
    this.existingImageUrls = const [],
    this.existingVideoUrl,
    this.capturedImages = const [],
    this.capturedVideo,
    this.imagesToDelete = const [],
    this.videosToDelete = const [],
  });

  UpdatePostState copyWith({
    CubitStates? updatePostState,
    CubitStates? categoryState,
    List<CategoryModel>? categories,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? draftText,
    String? selectedCategoryId,
    String? errorMessage,
    bool? isAiLoading,
    AddPostEnum? resolvedPostType,
    String? editPostId,
    List<String>? existingImageUrls,
    Object? existingVideoUrl = _existingVideoSentinel,
    List<File>? capturedImages,
    Object? capturedVideo = _capturedVideoSentinel,
    List<String>? imagesToDelete,
    List<String>? videosToDelete,
  }) {
    return UpdatePostState(
      updatePostState: updatePostState ?? this.updatePostState,
      categoryState: categoryState ?? this.categoryState,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      draftText: draftText ?? this.draftText,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage,
      isAiLoading: isAiLoading ?? this.isAiLoading,
      resolvedPostType: resolvedPostType ?? this.resolvedPostType,
      editPostId: editPostId ?? this.editPostId,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      existingVideoUrl: identical(existingVideoUrl, _existingVideoSentinel)
          ? this.existingVideoUrl
          : (existingVideoUrl as String?),
      capturedImages: capturedImages ?? this.capturedImages,
      capturedVideo: identical(capturedVideo, _capturedVideoSentinel)
          ? this.capturedVideo
          : (capturedVideo as XFile?),
      imagesToDelete: imagesToDelete ?? this.imagesToDelete,
      videosToDelete: videosToDelete ?? this.videosToDelete,
    );
  }
}

const _existingVideoSentinel = Object();
const _capturedVideoSentinel = Object();
