class LoginResponse {
  final String? token;
  final String? userId;
  final String? studentId;
  final String? username;
  final String? name;
  final String? department;
  final String? className;
  final bool? success;
  final String? message;
  final Map<String, dynamic>? extra;

  LoginResponse({
    this.token,
    this.userId,
    this.studentId,
    this.username,
    this.name,
    this.department,
    this.className,
    this.success,
    this.message,
    this.extra,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'token',
        'userId',
        'studentId',
        'username',
        'name',
        'department',
        'className',
        'success',
        'message',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return LoginResponse(
      token: json['token'] as String?,
      userId: json['userId'] as String?,
      studentId: json['studentId'] as String?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      department: json['department'] as String?,
      className: json['className'] as String?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (token != null) 'token': token,
      if (userId != null) 'userId': userId,
      if (studentId != null) 'studentId': studentId,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (department != null) 'department': department,
      if (className != null) 'className': className,
      if (success != null) 'success': success,
      if (message != null) 'message': message,
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }

  bool get isSuccess => success ?? true;
}
