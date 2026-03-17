import 'dart:async';

class ProfileUpdateEvent {
  final String name;
  final String image;
  final String username;

  ProfileUpdateEvent({
    required this.name,
    required this.image,
    required this.username,
  });
}

class ProfileEventBus {
  ProfileEventBus._privateConstructor();
  static final ProfileEventBus _instance = ProfileEventBus._privateConstructor();
  static ProfileEventBus get instance => _instance;

  final _controller = StreamController<ProfileUpdateEvent>.broadcast();
  Stream<ProfileUpdateEvent> get onProfileUpdated => _controller.stream;

  void fire(ProfileUpdateEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
