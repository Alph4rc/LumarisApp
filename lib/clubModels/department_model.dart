import 'staff_model.dart';

class DepartmentModel {
  final String key;
  final String name;
  final String? description;
  final List<StaffModel> staffs;
  final List<dynamic> projects; // 项目类型未在API文档中明确指定

  DepartmentModel({
    required this.key,
    required this.name,
    this.description,
    required this.staffs,
    required this.projects,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      staffs: (json['staffs'] as List?)?.map((e) => StaffModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      projects: json['projects'] as List? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'staffs': staffs.map((e) => e.toJson()).toList(),
      'projects': projects,
    };
  }
}