class TaskModel {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final bool status;
  final String id;

  TaskModel({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.id,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as bool,
      id: json['id'] as String,
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
    };
  }
}