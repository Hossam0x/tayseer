import 'dart:async';

enum ProfileEventUserType { advisor, user }

class ProfileUpdateEvent {
  final String name;
  final String image;
  final String username;

  /// ID of the user who fired the event — used to filter listeners
  final String? userId;

  /// Type of the user who fired the event
  final ProfileEventUserType userType;

  ProfileUpdateEvent({
    required this.name,
    required this.image,
    required this.username,
    this.userId,
    this.userType = ProfileEventUserType.advisor,
  });
}

class ProfileEventBus {
  ProfileEventBus._privateConstructor();
  static final ProfileEventBus _instance =
      ProfileEventBus._privateConstructor();
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
