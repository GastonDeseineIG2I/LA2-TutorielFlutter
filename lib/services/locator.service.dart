import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

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
    // locator.registerLazySingleton<UserService>(() => UserApiService());
  } else {
    // locator.registerLazySingleton<UserService>(() => UserOfflineService());
  }
}
