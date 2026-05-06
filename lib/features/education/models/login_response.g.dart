// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String?,
      userId: json['userId'] as String?,
      studentId: json['studentId'] as String?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      department: json['department'] as String?,
      className: json['className'] as String?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('token', instance.token);
  writeNotNull('userId', instance.userId);
  writeNotNull('studentId', instance.studentId);
  writeNotNull('username', instance.username);
  writeNotNull('name', instance.name);
  writeNotNull('department', instance.department);
  writeNotNull('className', instance.className);
  writeNotNull('success', instance.success);
  writeNotNull('message', instance.message);
  return val;
}
