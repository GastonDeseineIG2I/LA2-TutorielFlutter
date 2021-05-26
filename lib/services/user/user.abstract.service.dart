import 'package:tutoriel_flutter/models/user.model.dart';

abstract class UserService {
  Future<int> createUser(User user);
  Future<int> login(User user);
  Future<int> logout();
  Future<User> getCurrentUser(User user);
}