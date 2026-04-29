int parseSchemaInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return int.parse(value);
  }
  return fallback;
}

double parseSchemaDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.parse(value);
  }
  return fallback;
}

String parseSchemaString(dynamic value, {String fallback = ''}) {
  return value?.toString() ?? fallback;
}

bool parseSchemaBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  return fallback;
}

List<int> parseSchemaIntList(dynamic value) {
  if (value is List) {
    return value.map(parseSchemaInt).toList();
  }
  return <int>[];
}

List<String> parseSchemaStringList(dynamic value) {
  if (value is List) {
    return value.map(parseSchemaString).toList();
  }
  return <String>[];
}
