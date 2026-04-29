import 'package:json_annotation/json_annotation.dart';

import 'course_model.dart';
import 'exam_model.dart';
import 'semester_model.dart';
import 'schema_parsers.dart';

part 'edu_api_models.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseErrorResponse {
  @JsonKey(fromJson: parseSchemaBool)
  final bool success;
  @JsonKey(fromJson: parseSchemaString)
  final String message;

  const CourseErrorResponse({
    required this.success,
    required this.message,
  });

  factory CourseErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$CourseErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseErrorResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CourseResultResponse {
  @JsonKey(fromJson: parseSchemaBool)
  final bool success;
  @JsonKey(fromJson: _courseListFromJson)
  final List<CourseModel> data;
  @JsonKey(includeIfNull: false)
  final String? expirationTime;

  const CourseResultResponse({
    required this.success,
    required this.data,
    this.expirationTime,
  });

  factory CourseResultResponse.fromJson(Map<String, dynamic> json) =>
      _$CourseResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseResultResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ErrorResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String error;

  const ErrorResponse({required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ErrorWithMessageResponse {
  @JsonKey(fromJson: parseSchemaString)
  final String message;
  @JsonKey(fromJson: parseSchemaString)
  final String error;

  const ErrorWithMessageResponse({
    required this.message,
    required this.error,
  });

  factory ErrorWithMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorWithMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorWithMessageResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExamResponse {
  @JsonKey(fromJson: _examListFromJson)
  final List<ExamItem> exams;
  @JsonKey(fromJson: parseSchemaBool)
  final bool canClick;
  final String? error;

  const ExamResponse({
    required this.exams,
    required this.canClick,
    this.error,
  });

  factory ExamResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SemesterResult {
  @JsonKey(fromJson: _semesterListFromJson)
  final List<SemesterModel> data;

  const SemesterResult({required this.data});

  factory SemesterResult.fromJson(Map<String, dynamic> json) =>
      _$SemesterResultFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterResultToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TimeModel {
  final String? startTime;
  final String? endTime;

  const TimeModel({
    this.startTime,
    this.endTime,
  });

  factory TimeModel.fromJson(Map<String, dynamic> json) =>
      _$TimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimeModelToJson(this);
}

List<CourseModel> _courseListFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return <CourseModel>[];
}

List<ExamItem> _examListFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => ExamItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return <ExamItem>[];
}

List<SemesterModel> _semesterListFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((item) => SemesterModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return <SemesterModel>[];
}
