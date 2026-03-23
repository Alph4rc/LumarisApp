import 'dart:convert';

class PlanCourse {
  String name;
  String lessonType;
  String examMode;
  String courseTypeName;
  double credits;
  String termStr;

  PlanCourse({
    this.name = "",
    this.lessonType = "",
    this.examMode = "",
    this.courseTypeName = "",
    this.credits = 0.0,
    this.termStr = "",
  });

  // 将对象转换为Map以便JSON编码
  Map<String, dynamic> toJson() => {
        'name': name,
        'lessonType': lessonType,
        'examMode': examMode,
        'courseTypeName': courseTypeName,
        'credits': credits,
        'termStr': termStr,
      };

  // 从Map创建PlanCourse对象
  factory PlanCourse.fromJson(Map<String, dynamic> json) {
    return PlanCourse(
      name: json['name'] as String? ?? "",
      lessonType: json['lessonType'] as String? ?? "",
      examMode: json['examMode'] as String? ?? "",
      courseTypeName: json['courseTypeName'] as String? ?? "",
      credits: json['credits'] == null
          ? 0.0
          : double.parse(json['credits'].toString()),
      termStr: json['termStr'] as String? ?? "",
    );
  }

  // 将对象序列化为JSON字符串
  String toJsonString() => json.encode(toJson());

  // 从JSON字符串创建PlanCourse对象
  factory PlanCourse.fromJsonString(String jsonString) =>
      PlanCourse.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}

class PlanCourseList {
  List<PlanCourse> courses;
  String term;

  PlanCourseList({
    this.courses = const [],
    this.term = "",
  });

  // 将对象转换为Map以便JSON编码
  Map<String, dynamic> toJson() => {
        term: courses.map((course) => course.toJson()).toList(),
      };

  // 从Map创建PlanCourseList对象
  factory PlanCourseList.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return PlanCourseList();
    }

    // 获取第一个键值对
    String term = json.keys.first;
    List<dynamic> courseData = json[term];

    return PlanCourseList(
      term: term,
      courses: courseData
          .map((courseJson) => PlanCourse.fromJson(courseJson))
          .toList(),
    );
  }

  factory PlanCourseList.fromMap(String term, List<dynamic> courses) =>
      PlanCourseList(
        term: term,
        courses: courses.map<PlanCourse>((e) {
          if (e is PlanCourse) {
            return e;
          }
          return PlanCourse.fromJson(e as Map<String, dynamic>);
        }).toList(),
      );
}
