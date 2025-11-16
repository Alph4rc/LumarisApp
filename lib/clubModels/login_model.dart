class LoginModel {
  final String userId;
  final String password;
  final bool rememberMe;

  LoginModel({
    required this.userId,
    required this.password,
    required this.rememberMe,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['userId'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}