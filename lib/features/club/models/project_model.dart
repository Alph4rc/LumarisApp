class ProjectModel {
  final String title;
  final String id;
  final String description;
  final String? startTime;
  final String? endTime;

  ProjectModel({
    required this.title,
    required this.id,
    required this.description,
    this.startTime,
    this.endTime,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      title: json['title'] as String,
      id: json['id'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
