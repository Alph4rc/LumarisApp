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
    final Map<String, String> extra = <String, String>{};
    for (final key in json.keys) {
      if (!['startTime', 'endTime', 'semester'].contains(key)) {
        final value = json[key];
        if (value is String) {
          extra[key] = value;
        }
      }
    }

    return TimeInfo(
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
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
