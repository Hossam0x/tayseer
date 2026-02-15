import 'package:flutter_bloc/flutter_bloc.dart';

class ConsultationTopicsCubit extends Cubit<Set<String>> {
  ConsultationTopicsCubit() : super({});

  void toggleTopic(String topic) {
    final updatedTopics = Set<String>.from(state);
    if (updatedTopics.contains(topic)) {
      updatedTopics.remove(topic);
    } else {
      updatedTopics.add(topic);
    }
    emit(updatedTopics);
  }

  void selectTopics(List<String> topics) {
    emit(Set<String>.from(topics));
  }
}
