import 'project_model.dart';
import 'task_model.dart';

class StaffModel {
  final String userId;
  final String name;
  final String identity;
  final List<ProjectModel> projects;
  final List<TaskModel> tasks;

  StaffModel({
    required this.userId,
    required this.name,
    required this.identity,
    required this.projects,
    required this.tasks,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      identity: json['identity'] as String,
      projects: (json['projects'] as List?)
              ?.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tasks: (json['tasks'] as List?)
              ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'identity': identity,
      'projects': projects.map((e) => e.toJson()).toList(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }
}
