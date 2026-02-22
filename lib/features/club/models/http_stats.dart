class HttpStats {
  final int? totalRequests;
  final int? successfulRequests;
  final int? failedRequests;
  final double? avgResponseTime;
  final double? minResponseTime;
  final double? maxResponseTime;
  final int? requestsPerSecond;
  final Map<String, int>? endpointStats;
  final Map<String, dynamic>? extra;

  HttpStats({
    this.totalRequests,
    this.successfulRequests,
    this.failedRequests,
    this.avgResponseTime,
    this.minResponseTime,
    this.maxResponseTime,
    this.requestsPerSecond,
    this.endpointStats,
    this.extra,
  });

  factory HttpStats.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'totalRequests',
        'successfulRequests',
        'failedRequests',
        'avgResponseTime',
        'minResponseTime',
        'maxResponseTime',
        'requestsPerSecond',
        'endpointStats',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return HttpStats(
      totalRequests: json['totalRequests'] as int?,
      successfulRequests: json['successfulRequests'] as int?,
      failedRequests: json['failedRequests'] as int?,
      avgResponseTime: (json['avgResponseTime'] as num?)?.toDouble(),
      minResponseTime: (json['minResponseTime'] as num?)?.toDouble(),
      maxResponseTime: (json['maxResponseTime'] as num?)?.toDouble(),
      requestsPerSecond: json['requestsPerSecond'] as int?,
      endpointStats: json['endpointStats'] != null
          ? Map<String, int>.from(
              json['endpointStats'] as Map,
            )
          : null,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (totalRequests != null) 'totalRequests': totalRequests,
      if (successfulRequests != null)
        'successfulRequests': successfulRequests,
      if (failedRequests != null) 'failedRequests': failedRequests,
      if (avgResponseTime != null) 'avgResponseTime': avgResponseTime,
      if (minResponseTime != null) 'minResponseTime': minResponseTime,
      if (maxResponseTime != null) 'maxResponseTime': maxResponseTime,
      if (requestsPerSecond != null) 'requestsPerSecond': requestsPerSecond,
      if (endpointStats != null) 'endpointStats': endpointStats,
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }
}
