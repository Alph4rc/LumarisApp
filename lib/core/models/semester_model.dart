import 'package:hive/hive.dart';

part 'semester_model.g.dart';

@HiveType(typeId: 3)
class SemesterModel {
  @HiveField(0)
  final String semester;
  @HiveField(1)
  final String name;

  SemesterModel({required this.semester, required this.name});

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: (json['value'] ?? '').toString(),
      name: (json['text'] ?? '').toString(),
    );
  }

  Map<String, String> toJson() {
    return {
      'value': semester,
      'text': name,
    };
  }
}
