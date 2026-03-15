import 'dart:async';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

class UploadingStoryEvent {
  final CubitStates state;
  final double progress;
  UploadingStoryEvent({required this.state, required this.progress});
}

class StoriesEventBus {
  StoriesEventBus._privateConstructor();
  static final StoriesEventBus _instance = StoriesEventBus._privateConstructor();
  static StoriesEventBus get instance => _instance;

  final _myStoriesController = StreamController<UserStoriesModel?>.broadcast();
  Stream<UserStoriesModel?> get onMyStoriesUpdated => _myStoriesController.stream;

  final _uploadController = StreamController<UploadingStoryEvent>.broadcast();
  Stream<UploadingStoryEvent> get onUploadProgress => _uploadController.stream;

  void updateMyStories(UserStoriesModel? myStories) {
    _myStoriesController.add(myStories);
  }

  void updateUploadProgress(CubitStates state, double progress) {
    _uploadController.add(UploadingStoryEvent(state: state, progress: progress));
  }

  void dispose() {
    _myStoriesController.close();
    _uploadController.close();
  }
}
