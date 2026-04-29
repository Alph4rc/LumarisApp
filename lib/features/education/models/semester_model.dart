import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'semester_model.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 3)
class SemesterModel {
  @JsonKey(name: 'value', fromJson: parseSchemaString)
  @HiveField(0)
  final String semester;
  @JsonKey(name: 'text', fromJson: parseSchemaString)
  @HiveField(1)
  final String name;

  SemesterModel({required this.semester, required this.name});

  factory SemesterModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterModelFromJson(json);

  Map<String, String> toJson() =>
      _$SemesterModelToJson(this).cast<String, String>();
}
