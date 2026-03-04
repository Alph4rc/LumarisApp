import 'student_model.dart';

class TodoModel {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final bool status;
  final String id;
  final StudentModel? student;
  final String studentId;
  final DateTime createdTime;

  TodoModel({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.id,
    this.student,
    required this.studentId,
    required this.createdTime,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as bool,
      id: json['id'] as String,
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      studentId: json['studentId'] as String,
      createdTime: DateTime.parse(json['createdTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'id': id,
      'student': student?.toJson(),
      'studentId': studentId,
      'createdTime': createdTime.toIso8601String(),
    };
  }
}
