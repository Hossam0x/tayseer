import 'dart:async';

/// Event bus مخصص لمزامنة فيديو المستشار بين
/// EditPersonalDataView و ProfileView (certificates tab) فقط.
class AdvisorVideoUpdatedEvent {
  final String videoUrl;
  AdvisorVideoUpdatedEvent(this.videoUrl);
}

class AdvisorVideoEventBus {
  AdvisorVideoEventBus._();
  static final AdvisorVideoEventBus instance = AdvisorVideoEventBus._();

  final _controller = StreamController<AdvisorVideoUpdatedEvent>.broadcast();

  Stream<AdvisorVideoUpdatedEvent> get onVideoUpdated => _controller.stream;

  void fire(String newVideoUrl) {
    _controller.add(AdvisorVideoUpdatedEvent(newVideoUrl));
  }

  void dispose() => _controller.close();
}
