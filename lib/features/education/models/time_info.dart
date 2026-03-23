import 'edu_api_models.dart';

class TimeInfo {
  final String? startTime;
  final String? endTime;
  final String? semester;
  final Map<String, String>? extra;

  TimeInfo({
    this.startTime,
    this.endTime,
    this.semester,
    this.extra,
  });

  factory TimeInfo.fromJson(Map<String, dynamic> json) {
    final timeModel = TimeModel.fromJson(json);
    final extra = <String, String>{};
    for (final entry in json.entries) {
      if (entry.key == 'startTime' ||
          entry.key == 'endTime' ||
          entry.key == 'semester') {
        continue;
      }
      final value = entry.value;
      if (value is String) {
        extra[entry.key] = value;
      }
    }

    return TimeInfo(
      startTime: timeModel.startTime,
      endTime: timeModel.endTime,
      semester: json['semester'] as String?,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (semester != null) 'semester': semester,
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }

  String? operator [](String key) {
    switch (key) {
      case 'startTime':
        return startTime;
      case 'endTime':
        return endTime;
      case 'semester':
        return semester;
      default:
        return extra?[key];
    }
  }
}
