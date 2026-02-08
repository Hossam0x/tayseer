import 'package:equatable/equatable.dart';
import 'package:tayseer/my_import.dart';

class AddStoryState extends Equatable {
  final CubitStates addStoryState;
  final String? errorMessage;
  final List<AssetEntity> selectedImages;
  final List<File> capturedImages;
  final List<XFile> selectedVideos;
  final XFile? capturedVideo;
  final String draftText;
  final bool isAiLoading;

  const AddStoryState({
    this.addStoryState = CubitStates.initial,
    this.errorMessage,
    this.selectedImages = const [],
    this.capturedImages = const [],
    this.selectedVideos = const [],
    this.capturedVideo,
    this.draftText = '',
    this.isAiLoading = false,
  });

  AddStoryState copyWith({
    CubitStates? addStoryState,
    String? errorMessage,
    List<AssetEntity>? selectedImages,
    List<File>? capturedImages,
    List<XFile>? selectedVideos,
    XFile? capturedVideo,
    String? draftText,
    bool? isAiLoading,
  }) {
    return AddStoryState(
      addStoryState: addStoryState ?? this.addStoryState,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImages: selectedImages ?? this.selectedImages,
      capturedImages: capturedImages ?? this.capturedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      capturedVideo: capturedVideo ?? this.capturedVideo,
      draftText: draftText ?? this.draftText,
      isAiLoading: isAiLoading ?? this.isAiLoading,
    );
  }

  @override
  List<Object?> get props => [
    addStoryState,
    errorMessage,
    selectedImages,
    capturedImages,
    selectedVideos,
    capturedVideo,
    draftText,
    isAiLoading,
  ];
}
