import 'package:tutoriel_flutter/models/topic.model.dart';

abstract class TopicService {
  Future<int> createTopic(Topic topic);
  Future<List<Topic>> getTopics();
  Future<Topic> getTopic(int id);
}