class DataChangeStats {
  final int? totalChangeCount;
  final List<EntityChangeStat>? topChangedEntities;
  final String? entityType;
  final int? top;
  final DateTime? timestamp;
  final Map<String, dynamic>? extra;

  DataChangeStats({
    this.totalChangeCount,
    this.topChangedEntities,
    this.entityType,
    this.top,
    this.timestamp,
    this.extra,
  });

  factory DataChangeStats.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? entitiesJson = json['topChangedEntities'];
    final List<EntityChangeStat>? entities = entitiesJson?.isNotEmpty == true
        ? entitiesJson!
            .map((e) => EntityChangeStat.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'totalChangeCount',
        'topChangedEntities',
        'entityType',
        'top',
        'timestamp',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return DataChangeStats(
      totalChangeCount: json['totalChangeCount'] as int?,
      topChangedEntities: entities,
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
      if (totalChangeCount != null) 'totalChangeCount': totalChangeCount,
      if (topChangedEntities != null)
        'topChangedEntities':
            topChangedEntities!.map((e) => e.toJson()).toList(),
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

class EntityChangeStat {
  final String? entityId;
  final String? entityName;
  final int? changeCount;
  final DateTime? lastChangeTime;
  final Map<String, dynamic>? extra;

  EntityChangeStat({
    this.entityId,
    this.entityName,
    this.changeCount,
    this.lastChangeTime,
    this.extra,
  });

  factory EntityChangeStat.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = <String, dynamic>{};
    for (final key in json.keys) {
      if (![
        'entityId',
        'entityName',
        'changeCount',
        'lastChangeTime',
      ].contains(key)) {
        extra[key] = json[key];
      }
    }

    return EntityChangeStat(
      entityId: json['entityId'] as String?,
      entityName: json['entityName'] as String?,
      changeCount: json['changeCount'] as int?,
      lastChangeTime: json['lastChangeTime'] != null
          ? DateTime.parse(json['lastChangeTime'] as String)
          : null,
      extra: extra.isEmpty ? null : extra,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (entityId != null) 'entityId': entityId,
      if (entityName != null) 'entityName': entityName,
      if (changeCount != null) 'changeCount': changeCount,
      if (lastChangeTime != null)
        'lastChangeTime': lastChangeTime!.toIso8601String(),
    };

    if (extra != null) {
      json.addAll(extra!);
    }

    return json;
  }
}
