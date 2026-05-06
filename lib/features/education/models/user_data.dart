import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'user_data.g.dart';

@JsonSerializable(explicitToJson: true)
class UserData {
  @JsonKey(fromJson: parseSchemaString)
  final String studentId;
  @JsonKey(fromJson: parseSchemaString)
  final String cookie;

  UserData({required this.studentId, required this.cookie});

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
