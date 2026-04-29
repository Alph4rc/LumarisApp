// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edu_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseErrorResponse _$CourseErrorResponseFromJson(Map<String, dynamic> json) =>
    CourseErrorResponse(
      success: parseSchemaBool(json['success']),
      message: parseSchemaString(json['message']),
    );

Map<String, dynamic> _$CourseErrorResponseToJson(
        CourseErrorResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

CourseResultResponse _$CourseResultResponseFromJson(
        Map<String, dynamic> json) =>
    CourseResultResponse(
      success: parseSchemaBool(json['success']),
      data: _courseListFromJson(json['data']),
      expirationTime: json['expirationTime'] as String?,
    );

Map<String, dynamic> _$CourseResultResponseToJson(
    CourseResultResponse instance) {
  final val = <String, dynamic>{
    'success': instance.success,
    'data': instance.data.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('expirationTime', instance.expirationTime);
  return val;
}

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      error: parseSchemaString(json['error']),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
    };

ErrorWithMessageResponse _$ErrorWithMessageResponseFromJson(
        Map<String, dynamic> json) =>
    ErrorWithMessageResponse(
      message: parseSchemaString(json['message']),
      error: parseSchemaString(json['error']),
    );

Map<String, dynamic> _$ErrorWithMessageResponseToJson(
        ErrorWithMessageResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'error': instance.error,
    };

ExamResponse _$ExamResponseFromJson(Map<String, dynamic> json) => ExamResponse(
      exams: _examListFromJson(json['exams']),
      canClick: parseSchemaBool(json['canClick']),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ExamResponseToJson(ExamResponse instance) =>
    <String, dynamic>{
      'exams': instance.exams.map((e) => e.toJson()).toList(),
      'canClick': instance.canClick,
      'error': instance.error,
    };

SemesterResult _$SemesterResultFromJson(Map<String, dynamic> json) =>
    SemesterResult(
      data: _semesterListFromJson(json['data']),
    );

Map<String, dynamic> _$SemesterResultToJson(SemesterResult instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

TimeModel _$TimeModelFromJson(Map<String, dynamic> json) => TimeModel(
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );

Map<String, dynamic> _$TimeModelToJson(TimeModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('startTime', instance.startTime);
  writeNotNull('endTime', instance.endTime);
  return val;
}
