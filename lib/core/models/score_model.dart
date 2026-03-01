import 'package:hive/hive.dart';
import 'package:ios_club_app/core/models/semester_model.dart';

part 'score_model.g.dart';

@HiveType(typeId: 1)
class ScoreModel {
  @HiveField(0)
  String name;
  @HiveField(1)
  String lessonCode;
  @HiveField(2)
  String lessonName;
  @HiveField(3)
  String grade;
  @HiveField(4)
  String gpa;
  @HiveField(5)
  String gradeDetail;
  @HiveField(6)
  String credit;
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
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      name: json['name'] ?? '',
      lessonCode: json['lessonCode'] ?? '',
      lessonName: json['lessonName'] ?? '',
      grade: json['grade'] ?? '',
      gpa: json['gpa'] ?? '',
      gradeDetail: (json['gradeDetail'] ?? '').toString(),
      credit: (json['credit'] ?? '').toString(),
      isMinor: json['isMinor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lessonCode': lessonCode,
      'lessonName': lessonName,
      'grade': grade,
      'gpa': gpa,
      'gradeDetail': gradeDetail,
      'credit': credit,
      'isMinor': isMinor,
    };
  }
}

@HiveType(typeId: 2)
class ScoreList {
  @HiveField(0)
  List<ScoreModel> list;
  @HiveField(1)
  SemesterModel semester;

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((x) => x.toJson()).toList(),
      'semester': semester.toJson(),
    };
  }

  ScoreList.fromJson(Map<String, dynamic> json)
      : list = (json['list'] as List? ?? []).map((x) {
          try {
            return ScoreModel.fromJson(x as Map<String, dynamic>);
          } catch (_) {
            return ScoreModel();
          }
        }).toList(),
        semester = (() {
          try {
            return SemesterModel.fromJson(
                json['semester'] as Map<String, dynamic>);
          } catch (_) {
            return SemesterModel(semester: '', name: '');
          }
        })();

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
