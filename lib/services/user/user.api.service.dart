import 'dart:convert';

import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/services/user/user.abstract.service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';

class UserApiService extends UserService {
  @override
  Future<int> createUser(User user) async {
    print(user.toJson());
    final response = await http.post(Uri.http(API_URL, 'v1/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    if (response.statusCode == 201) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return 0;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to create user');
    }
  }

  @override
  Future<int> login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.http(API_URL, 'v1/authentication/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': user.name,
          'password': user.password
        }));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      user.id = jsonDecode(response.body)['idUser'];
      user.token = jsonDecode(response.body)['token'];
      prefs.setString('user', json.encode(user));
      print(prefs.getString('user'));
      return 0;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      print(jsonDecode(response.body));
      throw Exception('Failed to login');
    }
  }

  @override
  Future<int> logout() async {
    String? token;
    http.Response response;
    final prefs = await SharedPreferences.getInstance().then((value) async {
      token = value.getString('token');
      response = await http.post(Uri.http(API_URL, 'v1/authentication/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'token': '$token'
          });

      if(response.statusCode == 200){
        return 0;
      }
      else{
        throw Exception('Failed to login');
      }
    });
    return 0;
  }

  @override
  Future<User> getCurrentUser(User user) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }


}
