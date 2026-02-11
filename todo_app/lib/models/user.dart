class User {
  final String username;
  final String? password;
  final String id_;

  User({required this.username, this.password, required this.id_});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(username: json['username'], id_: json['id_']);
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
