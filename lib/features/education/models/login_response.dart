import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
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
  @JsonKey(includeFromJson: false, includeToJson: false)
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
    final generated = _$LoginResponseFromJson(json);
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
      token: generated.token,
      userId: generated.userId,
      studentId: generated.studentId,
      username: generated.username,
      name: generated.name,
      department: generated.department,
      className: generated.className,
      success: generated.success,
      message: generated.message,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$LoginResponseToJson(this);

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }

  bool get isSuccess => success ?? true;
}
