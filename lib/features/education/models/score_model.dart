import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'score_model.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
class ScoreModel {
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(0)
  String name;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(1)
  String lessonCode;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(2)
  String lessonName;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(3)
  String grade;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(4)
  String gpa;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(5)
  String gradeDetail;
  @JsonKey(fromJson: parseSchemaString)
  @HiveField(6)
  String credit;
  @JsonKey(fromJson: parseSchemaBool)
  @HiveField(7)
  bool isMinor;

  ScoreModel({
    this.name = '',
    this.lessonCode = '',
    this.lessonName = '',
    this.grade = '',
    this.gpa = '',
    this.gradeDetail = '',
    this.credit = '',
    this.isMinor = false,
  });

  // 如果需要从 JSON 创建对象
  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 2)
class ScoreList {
  @HiveField(0)
  List<ScoreModel> list;
  @HiveField(1)
  SemesterModel semester;

  Map<String, dynamic> toJson() => _$ScoreListToJson(this);

  factory ScoreList.fromJson(Map<String, dynamic> json) =>
      _$ScoreListFromJson(json);

  ScoreList({required this.semester, required this.list});

  /// 总学分
  double get totalCredit {
    double credit = 0;
    for (var item in list) {
      if (item.gpa == '' || item.credit == '0') continue;
      final a = double.parse(item.gpa);
      if (a == 0) {
        continue;
      }
      credit += double.parse(item.credit);
    }
    return credit;
  }

  /// 总绩点
  double get totalGpa {
    double total = 0;
    double credit = 0;
    for (var item in list) {
      if (item.gpa == '' || item.credit == '0' || item.isMinor) continue;
      total += double.parse(item.credit);
      credit += double.parse(item.credit) * double.parse(item.gpa);
    }
    return credit / total;
  }

  /// 总课程数
  int get totalCourse {
    return list.where((x) {
      if (x.gpa == '' || x.credit == '0') return false;
      final a = double.parse(x.gpa);
      return a != 0;
    }).length;
  }

  static double getTotalGpa(List<ScoreList> scoreList) {
    double total = 0;
    for (var item in scoreList) {
      total += item.totalGpa;
    }
    return total / scoreList.length;
  }

  static double getTotalCredit(List<ScoreList> scoreList) {
    double total = 0;
    for (var item in scoreList) {
      total += item.totalCredit;
    }
    return total;
  }

  static int getTotalCourse(List<ScoreList> scoreList) {
    int total = 0;
    for (var item in scoreList) {
      total += item.totalCourse;
    }
    return total;
  }
}
