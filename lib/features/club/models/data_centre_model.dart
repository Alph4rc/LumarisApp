class DataCentreModel {
  late final int members;
  late final int departments;
  late final int staffs;
  late final int tasks;
  late final int projects;
  late final int resources;
  late final int todos;

  DataCentreModel({
    required this.members,
    required this.departments,
    required this.staffs,
    required this.tasks,
    required this.projects,
    required this.resources,
    required this.todos,
  });

  factory DataCentreModel.fromJson(Map<String, dynamic> json) {
    return DataCentreModel(
      members: json['members'],
      departments: json['departments'],
      staffs: json['staffs'],
      tasks: json['tasks'],
      projects: json['projects'],
      resources: json['resources'],
      todos: json['todos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'members': members,
      'departments': departments,
      'staffs': staffs,
      'tasks': tasks,
      'projects': projects,
      'resources': resources,
      'todos': todos,
    };
  }
}

class GradeCount {
  final String? grade;
  final int? value;

  GradeCount({this.grade, this.value});

  factory GradeCount.fromJson(Map<String, dynamic> json) {
    return GradeCount(
      grade: json['grade'] as String?,
      value: json['value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'value': value,
    };
  }
}
