import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/services/user/user.abstract.service.dart';

class UserOfflineService extends UserService {
  @override
  Future<int> createUser(User user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<int> login(User user) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<int> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<User> getCurrentUser(User user) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

}