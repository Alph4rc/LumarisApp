import 'course_model.dart';
import 'exam_model.dart';
import 'semester_model.dart';

class CourseErrorResponse {
  final bool success;
  final String message;

  const CourseErrorResponse({
    required this.success,
    required this.message,
  });

  factory CourseErrorResponse.fromJson(Map<String, dynamic> json) {
    return CourseErrorResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
    };
  }
}

class CourseResultResponse {
  final bool success;
  final List<CourseModel> data;
  final String? expirationTime;

  const CourseResultResponse({
    required this.success,
    required this.data,
    this.expirationTime,
  });

  factory CourseResultResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? <dynamic>[];
    return CourseResultResponse(
      success: json['success'] as bool? ?? false,
      data: rawData
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expirationTime: json['expirationTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'data': data.map((course) => course.toJson()).toList(),
      if (expirationTime != null) 'expirationTime': expirationTime,
    };
  }
}

class ErrorResponse {
  final String error;

  const ErrorResponse({required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(error: json['error'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'error': error};
  }
}

class ErrorWithMessageResponse {
  final String message;
  final String error;

  const ErrorWithMessageResponse({
    required this.message,
    required this.error,
  });

  factory ErrorWithMessageResponse.fromJson(Map<String, dynamic> json) {
    return ErrorWithMessageResponse(
      message: json['message'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'error': error,
    };
  }
}

class ExamResponse {
  final List<ExamItem> exams;
  final bool canClick;
  final String? error;

  const ExamResponse({
    required this.exams,
    required this.canClick,
    this.error,
  });

  factory ExamResponse.fromJson(Map<String, dynamic> json) {
    final rawExams = json['exams'] as List<dynamic>? ?? <dynamic>[];
    return ExamResponse(
      exams: rawExams
          .map((e) => ExamItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      canClick: json['canClick'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'exams': exams.map((exam) => exam.toJson()).toList(),
      'canClick': canClick,
      'error': error,
    };
  }
}

class SemesterResult {
  final List<SemesterModel> data;

  const SemesterResult({required this.data});

  factory SemesterResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? <dynamic>[];
    return SemesterResult(
      data: rawData
          .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': data.map((semester) => semester.toJson()).toList(),
    };
  }
}

class TimeModel {
  final String? startTime;
  final String? endTime;

  const TimeModel({
    this.startTime,
    this.endTime,
  });

  factory TimeModel.fromJson(Map<String, dynamic> json) {
    return TimeModel(
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}
