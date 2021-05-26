import 'package:tutoriel_flutter/models/topic.model.dart';
import 'package:tutoriel_flutter/services/topic/topic.abstract.service.dart';

class TopicOfflineService extends TopicService{
  @override
  Future<int> createTopic(Topic topic) {
    // TODO: implement createTopic
    throw UnimplementedError();
  }

  @override
  Future<List<Topic>> getTopics() {
    // TODO: implement listTopic
    throw UnimplementedError();
  }

  @override
  Future<Topic> getTopic(int id) {
    // TODO: implement readTopic
    throw UnimplementedError();
  }

}