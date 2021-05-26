import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:tutoriel_flutter/services/topic/topic.abstract.service.dart';
import 'package:tutoriel_flutter/services/topic/topic.api.service.dart';
import 'package:tutoriel_flutter/services/topic/topic.offline.sevice.dart';
import 'package:tutoriel_flutter/services/user/user.abstract.service.dart';
import 'package:tutoriel_flutter/services/user/user.api.service.dart';
import 'package:tutoriel_flutter/services/user/user.offline.service.dart';

import 'const.dart';

GetIt locator = GetIt.instance;

// Fonction qui test la réponse du serveur
Future<bool> ping() async {
  try {
    final response = await http.get(Uri.http(API_URL, 'ping')).timeout(
        new Duration(seconds: 5),
        onTimeout: () => throw new TimeoutException('TimeOut'));
    return response.body == 'pong';
  } catch (error) {
    return false;
  }
}

// Fonction permettant d'utiliser le bon service en fonction du cas de figure (Réponse de l'API ou non)
setupServiceLocator() async {
  if (await ping()) {
    locator.registerLazySingleton<UserService>(() => UserApiService());
    locator.registerLazySingleton<TopicService>(() => TopicApiService());
  } else {
    locator.registerLazySingleton<UserService>(() => UserOfflineService());
    locator.registerLazySingleton<TopicService>(() => TopicOfflineService());
  }
}
