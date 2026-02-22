class PerformanceData {
  final double? cpuUsage;
  final double? memoryUsage;
  final double? diskUsage;
  final int? requestCount;
  final int? errorCount;
  final double? avgResponseTime;
  final DateTime? timestamp;
  final Map<String, dynamic>? extra;

  PerformanceData({
    this.cpuUsage,
    this.memoryUsage,
    this.diskUsage,
    this.requestCount,
    this.errorCount,
    this.avgResponseTime,
    this.timestamp,
    this.extra,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'cpuUsage',
        'memoryUsage',
        'diskUsage',
        'requestCount',
        'errorCount',
        'avgResponseTime',
        'timestamp',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return PerformanceData(
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble(),
      memoryUsage: (json['memoryUsage'] as num?)?.toDouble(),
      diskUsage: (json['diskUsage'] as num?)?.toDouble(),
      requestCount: json['requestCount'] as int?,
      errorCount: json['errorCount'] as int?,
      avgResponseTime: (json['avgResponseTime'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (cpuUsage != null) 'cpuUsage': cpuUsage,
      if (memoryUsage != null) 'memoryUsage': memoryUsage,
      if (diskUsage != null) 'diskUsage': diskUsage,
      if (requestCount != null) 'requestCount': requestCount,
      if (errorCount != null) 'errorCount': errorCount,
      if (avgResponseTime != null) 'avgResponseTime': avgResponseTime,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }
}
