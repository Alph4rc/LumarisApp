class DataAccessStats {
  final int? totalAccessCount;
  final List<EntityAccessStat>? topAccessedEntities;
  final String? entityType;
  final int? top;
  final DateTime? timestamp;
  final Map<String, dynamic>? extra;

  DataAccessStats({
    this.totalAccessCount,
    this.topAccessedEntities,
    this.entityType,
    this.top,
    this.timestamp,
    this.extra,
  });

  factory DataAccessStats.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? entitiesJson = json['topAccessedEntities'];
    final List<EntityAccessStat>? entities = entitiesJson?.isNotEmpty == true
        ? entitiesJson!
            .map((e) => EntityAccessStat.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'totalAccessCount',
        'topAccessedEntities',
        'entityType',
        'top',
        'timestamp',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return DataAccessStats(
      totalAccessCount: json['totalAccessCount'] as int?,
      topAccessedEntities: entities,
      entityType: json['entityType'] as String?,
      top: json['top'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (totalAccessCount != null) 'totalAccessCount': totalAccessCount,
      if (topAccessedEntities != null)
        'topAccessedEntities':
            topAccessedEntities!.map((e) => e.toJson()).toList(),
      if (entityType != null) 'entityType': entityType,
      if (top != null) 'top': top,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }
}

class EntityAccessStat {
  final String? entityId;
  final String? entityName;
  final int? accessCount;
  final DateTime? lastAccessTime;
  final Map<String, dynamic>? extra;

  EntityAccessStat({
    this.entityId,
    this.entityName,
    this.accessCount,
    this.lastAccessTime,
    this.extra,
  });

  factory EntityAccessStat.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'entityId',
        'entityName',
        'accessCount',
        'lastAccessTime',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return EntityAccessStat(
      entityId: json['entityId'] as String?,
      entityName: json['entityName'] as String?,
      accessCount: json['accessCount'] as int?,
      lastAccessTime: json['lastAccessTime'] != null
          ? DateTime.parse(json['lastAccessTime'] as String)
          : null,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (entityId != null) 'entityId': entityId,
      if (entityName != null) 'entityName': entityName,
      if (accessCount != null) 'accessCount': accessCount,
      if (lastAccessTime != null)
        'lastAccessTime': lastAccessTime!.toIso8601String(),
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }
}
