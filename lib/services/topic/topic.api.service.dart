import 'dart:convert';

import 'package:tutoriel_flutter/models/topic.model.dart';
import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/services/topic/topic.abstract.service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';


class TopicApiService extends TopicService {
  @override
  Future<int> createTopic(Topic topic) async{
    final prefs = await SharedPreferences.getInstance();
    User user = User.fromJson(json.decode(prefs.getString('user')!));
    topic.user = user;
    final response = await http.post(Uri.http(API_URL, "v1/topics"),
      headers: <String, String>{
        'token': user.token!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(topic.toJson()));
    if(response.statusCode == 201) {
      return 0;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to create topic');
    }
  }

  @override
  Future<List<Topic>> getTopics() async{
    final prefs = await SharedPreferences.getInstance();
    User user = User.fromJson(json.decode(prefs.getString('user')!));
    final response = await http.get(Uri.http(API_URL, "v1/topics/fetchFromUser"),
        headers: <String, String>{
          'token': user.token!,
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if(response.statusCode == 200){
      return (jsonDecode(response.body) as List).map<Topic>((json) => Topic.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      // If the server did return a 204 NO RECORDS FOUND response,
      // then return []
      return [];
    } else {
      throw Exception('Failed to get topics');
    }

    throw UnimplementedError();
  }

  @override
  Future<Topic> getTopic(int id) {
    // TODO: implement readTopic
    throw UnimplementedError();
  }
  
}