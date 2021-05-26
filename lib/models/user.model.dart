class User {
  int? id;
  String? name;
  String? password;
  String? token;

  User({this.id, this.name, this.password, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        password: json['password'],
        token: json['token']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'password': password,
    'token': token
  };
}