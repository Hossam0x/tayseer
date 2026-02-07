import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/my_import.dart';

class AddStoryCubit extends Cubit<AddStoryState> {
  final StoriesRepository storiesRepository;
  final contentController = TextEditingController();

  AddStoryCubit(this.storiesRepository) : super(const AddStoryState());

  Future<void> createStory() async {
    emit(state.copyWith(addStoryState: CubitStates.loading));

    final List<File> imageFiles = [];
    // Convert AssetEntity to File
    for (var asset in state.selectedImages) {
      final file = await asset.file;
      if (file != null) imageFiles.add(file);
    }
    imageFiles.addAll(state.capturedImages);

    final List<XFile> videoFiles = [];
    if (state.capturedVideo != null) {
      videoFiles.add(state.capturedVideo!);
    }
    for (var video in state.selectedVideos) {
      videoFiles.add(video);
    }

    final result = await storiesRepository.createStories(
      content: contentController.text,
      images: imageFiles,
      videos: videoFiles,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            addStoryState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(addStoryState: CubitStates.success));
        contentController.clear();
      },
    );
  }

  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  void addCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages)..add(file);
    emit(state.copyWith(capturedImages: captured));
  }

  void removeCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages)..remove(file);
    emit(state.copyWith(capturedImages: captured));
  }

  void addCapturedVideo(XFile file) {
    emit(state.copyWith(capturedVideo: file));
  }

  void removeCapturedVideo() {
    emit(state.copyWith(capturedVideo: null));
  }

  void removeSelectedImage(AssetEntity asset) {
    final selected = List<AssetEntity>.from(state.selectedImages)
      ..remove(asset);
    emit(state.copyWith(selectedImages: selected));
  }

  void addSelectedImages(List<AssetEntity> assets) {
    final selected = List<AssetEntity>.from(state.selectedImages)
      ..addAll(assets);
    emit(state.copyWith(selectedImages: selected));
  }

  void addSelectedVideos(List<XFile> videos) {
    final selected = List<XFile>.from(state.selectedVideos)..addAll(videos);
    emit(state.copyWith(selectedVideos: selected));
  }

  Future<void> enhanceTextWithGemini(BuildContext context) async {
    final currentText = contentController.text;
    if (currentText.trim().isEmpty) return;

    emit(state.copyWith(isAiLoading: true));
    const apiKey =
        'AIzaSyAzkpmYLG58vfNtxPGvfh8Ynix02VNWnUg'; // Keep it for now as per AddPostCubit

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);
      final prompt =
          '''
You are a professional social media content creator.
Rewrite the text to be engaging and professional with emojis.
Return ONLY the rewritten text.
Input text: "$currentText"
''';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        contentController.text = response.text!;
        emit(state.copyWith(draftText: response.text!, isAiLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isAiLoading: false));
    }
  }
}
