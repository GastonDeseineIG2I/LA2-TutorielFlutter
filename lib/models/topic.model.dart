import 'package:tutoriel_flutter/models/user.model.dart';

class Topic {
  int? id;
  DateTime? creationDate;
  String? name;
  User? user;

  Topic({this.id, this.creationDate, this.name, this.user});

  factory Topic.fromJson(Map<String, dynamic> json) {

    return Topic(
        id: json['id'],
        creationDate: DateTime.parse(json['creationDate']),
        name: json['name'],
        user: User.fromJson(json['user']));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creationDate': creationDate,
    'name': name,
    'user': user
  };
}
