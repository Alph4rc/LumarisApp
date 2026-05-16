import 'school.dart';

class User {
  final String id;
  final String username;
  final String token;
  final School selectedSchool;

  const User({
    required this.id,
    required this.username,
    required this.token,
    required this.selectedSchool,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      token: json['token'] as String,
      selectedSchool: School.fromJson(json['selectedSchool'] as Map<String, dynamic>),
    );
  }
}
